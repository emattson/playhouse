defmodule Database.Catalog.Pack do
  use Database.Model

  schema "packs" do
    belongs_to :user, User

    field :name, :string

    timestamps()
  end

  def changeset(question, attrs) do
    required_fields = [:name]

    question
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
