defmodule FlopContext.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: FlopContext.Repo

  alias FlopContext.Schemas.Comment
  alias FlopContext.Schemas.Post
  alias FlopContext.Schemas.User

  @names [
    "Alice",
    "Bob",
    "Charlie",
    "Diana",
    "Edward",
    "Fiona",
    "George",
    "Hannah",
    "Ian",
    "Jane",
    "Kevin",
    "Laura",
    "Michael",
    "Nina",
    "Oscar",
    "Paula",
    "Quincy",
    "Rachel",
    "Sam",
    "Tina",
    "Umar",
    "Vera",
    "Walter",
    "Xena",
    "Yara",
    "Zane"
  ]

  @domains [
    "example.com",
    "test.com",
    "sample.org",
    "mydomain.net",
    "mail.com"
  ]

  @titles [
    "First Post",
    "Hello World",
    "Ecto and Elixir",
    "Functional Programming",
    "Concurrency in Elixir",
    "Testing with ExUnit",
    "Building APIs",
    "Phoenix Framework",
    "LiveView Magic",
    "Scaling Elixir"
  ]

  @comments [
    "Great post!",
    "Very informative.",
    "Thanks for sharing.",
    "I learned a lot.",
    "Awesome content.",
    "Keep it up!",
    "Looking forward to more.",
    "This was helpful.",
    "Interesting read.",
    "Good job!"
  ]

  def user_factory do
    %User{
      name: sequence(:name, @names),
      email: sequence(:email, &("#{String.downcase(&1)}@#{Enum.random(@domains)}")),
      age: :rand.uniform(70) + 10,
      active: Enum.random([true, false])
    }
  end

  def post_factory do
    %Post{
      title: sequence(:title, @titles),
      content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      published: Enum.random([true, false]),
      user: build(:user)
    }
  end

  def comment_factory do
    %Comment{
      content: sequence(:content, @comments),
      user: build(:user),
      post: build(:post)
    }
  end

  def user_with_posts_factory do
    user = build(:user)
    posts = build_list(3, :post, user: user)
    %{user | posts: posts}
  end

  def post_with_comments_factory do
    post = build(:post)
    comments = build_list(3, :comment, post: post)
    %{post | comments: comments}
  end
end
