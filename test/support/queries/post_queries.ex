defmodule FlopContext.Queries.PostQueries do
  use FlopQueries,
    schema: FlopContext.Schemas.Post

    def join_assocs(query, _join), do: query
end
