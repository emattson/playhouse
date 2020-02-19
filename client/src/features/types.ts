export interface GameState {
  gameID: string | null;
  players: Player[];
}

export interface ServerResponse {
  event: string;
  payload: any;
}

export interface Player {
  id: string;
  name: string;
  coins: number;
}
