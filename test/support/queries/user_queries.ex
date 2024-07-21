defmodule FlopContext.Queries.UserQueries do
  use FlopQueries,
    schema: FlopContext.Schemas.User

    def join_assocs(query, _join), do: query
end
