package authbootstrap

import (
	"context"
	"errors"
	"os"
	"strings"
	"sync"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	db "github.com/multica-ai/multica/server/pkg/db/generated"
)

var mu sync.Mutex

// IsAuthDisabled returns true when MULTICA_DISABLE_AUTH enables anonymous access.
func IsAuthDisabled() bool {
	v := strings.TrimSpace(os.Getenv("MULTICA_DISABLE_AUTH"))
	switch strings.ToLower(v) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}

// ResolveAnonymousUser returns the first user in the DB, or creates a bootstrap user.
// Used only when IsAuthDisabled() is true.
func ResolveAnonymousUser(ctx context.Context, q *db.Queries) (db.User, error) {
	if q == nil {
		return db.User{}, errors.New("nil db queries")
	}
	mu.Lock()
	defer mu.Unlock()

	u, err := q.GetFirstUser(ctx)
	if err == nil {
		return u, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return db.User{}, err
	}

	email := strings.TrimSpace(os.Getenv("MULTICA_DISABLE_AUTH_EMAIL"))
	if email == "" {
		email = "anon@multica.local"
	}

	if u2, err2 := q.GetUserByEmail(ctx, email); err2 == nil {
		return u2, nil
	}

	name := email
	if at := strings.Index(email, "@"); at > 0 {
		name = email[:at]
	}
	return q.CreateUser(ctx, db.CreateUserParams{
		Name:      name,
		Email:     email,
		AvatarUrl: pgtype.Text{},
	})
}
