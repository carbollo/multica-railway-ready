package handler

import (
	"net/http"

	"github.com/multica-ai/multica/server/internal/authbootstrap"
)

type AppConfig struct {
	CdnDomain    string `json:"cdn_domain"`
	AuthDisabled bool   `json:"auth_disabled"`
}

func (h *Handler) GetConfig(w http.ResponseWriter, r *http.Request) {
	config := AppConfig{AuthDisabled: authbootstrap.IsAuthDisabled()}
	if h.Storage != nil {
		config.CdnDomain = h.Storage.CdnDomain()
	}
	writeJSON(w, http.StatusOK, config)
}
