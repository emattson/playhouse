defmodule Game.GameServer do
  @moduledoc """
  Process that persists state for a live game for amount of time

  Uses ets to store instance of game
  """

  use GenServer

  require Logger

  @timeout :timer.hours(1)

  def start_link(game_code, questions) do
    GenServer.start_link(__MODULE__,
                         {game_code, questions},
                         name: via_tuple(game_code))
  end

  def game_state(game_code) do
    GenServer.call(via_tuple(game_code), :game_state)
  end

  def game_start(game_code) do
    GenServer.call(via_tuple(game_code), :game_start)
  end

  def game_end(game_code) do
    GenServer.call(via_tuple(game_code), :game_end)
  end

  def player_new(game_code, player) do
    GenServer.call(via_tuple(game_code), {:player_new, player})
  end

  def player_submit(game_code, submission, player_count) do
    GenServer.call(via_tuple(game_code), {:player_submit, submission, player_count})
  end

  def player_endorse(game_code, name, submission_id, player_count) do
    GenServer.call(via_tuple(game_code), {:player_endorse, name, submission_id, player_count})
  end

  def scene_next(game_code) do
    GenServer.call(via_tuple(game_code), :scene_next)
  end

  def act_next(game_code) do
    GenServer.call(via_tuple(game_code), :act_next)
  end

  def game_pid(game_code) do
    game_code
    |> via_tuple
    |> GenServer.whereis
  end

  def via_tuple(game_code) do
    {:via, Registry, {Game.GameRegistry, game_code}}
  end

  def init({game_code, pack}) do
    # TODO: Get questions and pack data from DB once we migrate away from Airtable
    questions = Game.QuestionCache.get_questions(pack)

    game = case :ets.lookup(:games_table, game_code) do
      [] ->
        game = Game.GamePlay.new(questions, [], pack)
        :ets.insert(:games_table, {game_code, game})
        game

      [{^game_code, game}] ->
        game
    end

    Logger.info("Spawned game server process named '#{game_code}'.")

    {:ok, game, @timeout}
  end

  def get_game_state(game) do
    current_act = Enum.at(game.acts, game.act - 1)
    %{
      question: question,
      answer: answer,
      pack: pack,
      instruction: instruction,
      question_type: question_type,
      answer_type: answer_type
    } = current_act

    %{
      act: game.act,
      scene: game.scene,
      players: game.players,
      pack: pack,
      question: question,
      questionType: question_type,
      answer: answer,
      answerType: answer_type,
      submissions: current_act.submissions,
      instruction: instruction
    }
  end

  def get_end_game_state(game) do
    %{
      act: game.act,
      scene: game.scene,
      players: game.players
    }
  end

  def handle_call(:game_state, _from, game) do
    {:reply, get_game_state(game), game, @timeout}
  end

  def handle_call({:player_new, player}, _from, game) do
    updated_game = Game.GamePlay.player_new(game, player)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_call({:player_submit, submission, player_count}, _from, game) do
    updated_game = Game.GamePlay.player_submit(game, submission, player_count)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_call({:player_endorse, name, submission_id, player_count}, _from, game) do
    updated_game = Game.GamePlay.player_endorse(game, name, submission_id, player_count)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_call(:game_start, _from, game) do
    updated_game = Game.GamePlay.start(game)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_call(:game_end, _from, game) do
    {:reply, get_end_game_state(game), game, @timeout}
  end

  def handle_call(:act_next, _from, game) do
    updated_game = Game.GamePlay.act_next(game)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_call(:scene_next, _from, game) do
    updated_game = Game.GamePlay.scene_next(game)

    :ets.insert(:games_table, {my_game_code(), updated_game})

    {:reply, get_game_state(updated_game), updated_game, @timeout}
  end

  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, _game) do
    :ets.delete(:games_table, my_game_code())
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  defp my_game_code do
    Registry.keys(Game.GameRegistry, self()) |> List.first
  end
end
