defmodule Database.Repo.Migrations.RemoveUserConstraints do
  use Ecto.Migration

  def change do
    alter table(:plays) do
      remove :user_id, references(:users), null: false
      add :user_id, references(:users), null: true
    end

    alter table(:packs) do
      remove :user_id, references(:users), null: false
      add :user_id, references(:users), null: true
    end

    alter table(:acts) do
      remove :user_id, references(:users), null: false
      add :user_id, references(:users), null: true
    end

    alter table(:questions) do
      modify :question_type, :integer, default: 0
      remove :user_id, references(:users), null: false
      add :user_id, references(:users), null: true
    end

    alter table(:answers) do
      modify :answer_type, :integer, default: 0
    end
  end
end
