// Package envbootstrap loads .env / .env.local before other packages read os.Getenv.
// 本機 go run 或 IDE 除錯時，工作目錄常為 Taipei-City-Dashboard-BE 或 repo 根目錄，兩者皆嘗試。
package envbootstrap

import (
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

func init() {
	for _, base := range []string{".", "Taipei-City-Dashboard-BE"} {
		envPath := filepath.Join(base, ".env")
		localPath := filepath.Join(base, ".env.local")
		if !isFile(envPath) && !isFile(localPath) {
			continue
		}
		// 先載入 .env，再以 .env.local 覆寫（與常見本機覆蓋順序一致）
		if isFile(envPath) {
			_ = godotenv.Load(envPath)
		}
		if isFile(localPath) {
			_ = godotenv.Overload(localPath)
		}
		return
	}
}

func isFile(path string) bool {
	st, err := os.Stat(path)
	return err == nil && !st.IsDir()
}
