defmodule FlopContext.Contexts.Posts do
  use FlopContext,
    schema: FlopContext.Schemas.Post,
    queries: FlopContext.Queries.PostQueries,
    singular: :post,
    plural: :posts
end
