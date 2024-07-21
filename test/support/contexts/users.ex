defmodule FlopContext.Contexts.Users do
  use FlopContext,
    schema: FlopContext.Schemas.User,
    queries: FlopContext.Queries.UserQueries,
    singular: :user,
    plural: :users
end
