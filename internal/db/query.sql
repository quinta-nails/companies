-- name: AddReserves :exec
INSERT INTO reserves (
    user_id,
    service_id,
    datetime
)
VALUES (
    $1,
    $2,
    $3
)
ON CONFLICT (user_id, service_id, datetime) DO NOTHING;