defmodule Database.Catalog do	
  use Database.Context

  def random_question do
    query =
      from Question,
      order_by: fragment("RANDOM()"),
      limit: 1

    Repo.one(query)
  end

  def generate_code do
    :io_lib.format("~4..0B", [:rand.uniform(10_000) - 1])
    |> List.to_string
  end

  def random_formatted_questions(size) do
    query =
      from q in Question,
      join: a in Answer, as: :answer, on: a.question_id == q.id,
      join: p in Pack, as: :pack, on: q.pack_id == p.id,
      order_by: fragment("RANDOM()"),
      limit: ^size

    Repo.all(from [q, answer: a, pack: p] in query, select: {q.content, a.content, p.name, q.instruction})
  end

  def list_questions() do
    Repo.all(Question)	
  end

  def pack_list() do
    Repo.all(Pack)	
  end

  def play_list() do
    Repo.all(Pack)
    |> Enum.map(fn p -> p.name end)
  end

  def question_types do
    %{
      text: 0,
      image: 1
    }
  end

  def answer_types do
    %{
      text: 0,
      color: 1,
      drawing: 2
    }
  end

  def endorsement_types do
    %{
      text: 0,
      color: 1,
      drawing: 2
    }
  end

  def pack_create(%User{} = user, attrs) do
    %Pack{}
    |> Pack.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end
end
