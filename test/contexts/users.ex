defmodule FlopContext.Contexts.Users do
  use FlopContext.Context,
    schema: FlopContext.Schemas.User,
    singular: :user,
    plural: :users
end
