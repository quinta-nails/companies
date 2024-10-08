package main

import (
	"context"
	"database/sql"
	"github.com/quinta-nails/companies/internal/db"
	pb "github.com/quinta-nails/protobuf/gen/go/companies"
)

func (s *Service) Reserve(ctx context.Context, in *pb.ReserveRequest) (*pb.ReserveResponse, error) {
	resp := &pb.ReserveResponse{}

	err := s.validator.Validate(in)
	if err != nil {
		return nil, err
	}

	err = s.db.AddReserves(ctx, db.AddReservesParams{
		UserID: sql.NullInt64{
			Int64: in.UserId,
			Valid: in.UserId > 0,
		},
		ServiceID: sql.NullInt64{
			Int64: in.ServiceId,
			Valid: in.ServiceId > 0,
		},
		Datetime: in.Datetime.AsTime(),
	})
	if err != nil {
		return nil, err
	}

	return resp, nil
}
