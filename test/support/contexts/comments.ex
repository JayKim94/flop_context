defmodule FlopContext.Contexts.Comments do
  use FlopContext,
    schema: FlopContext.Schemas.Comment,
    queries: FlopContext.Queries.CommentQueries,
    singular: :comment,
    plural: :comments
end
