defmodule FlopContext.Queries.CommentQueries do
  use FlopQueries,
    schema: FlopContext.Schemas.Comment

    def join_assocs(query, _join), do: query
end
