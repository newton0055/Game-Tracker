import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

actor GameTracker {

    type Status = {
        #Still_playing;
        #Finished_playing;
        #Want_to_play;
    };

    type Game = {
        id: Nat;
        name: Text;
        status: Status;
        createdAt: Time.Time;
        updatedAt: Time.Time;
    };

    stable var games: [Game] = [];
    stable var nextId: Nat = 0;

    public query func getGames() : async [Game] {
        return games;
    };

    public func addGame(name: Text, status: Status) : async Game {
        let newGame = {
            id = nextId;
            name = name;
            status = status;
            createdAt = Time.now();
            updatedAt = Time.now();
        };
        games := Array.append<Game>(games, [newGame]);
        nextId += 1;
        return newGame;
    };

    public func updateGame(id: Nat, status: Status) : async?Game {
        for (index in Iter.range(0, games.size())) {
            if (games[index].id == id) {
                let oldGame = games[index];
                let newGame = {
                    id = oldGame.id;
                    name = oldGame.name;
                    status = status;
                    createdAt = oldGame.createdAt;
                    updatedAt = Time.now();
                };
                games := Array.tabulate<Game>(games.size(), func(i) {
                    if (i == index) {
                        return newGame;
                    } else {
                        return games[i];
                    };
                });
                return?newGame;
            };
        };
        return null;
    };

    public func deleteGame(id: Nat) : async Bool {
        games := Array.filter<Game>(games, func(game) { game.id!= id });
        return true;
    };

    public func getGame(id: Nat) : async?Game {
        for (game in games.vals()) {
            if (game.id == id) {
                return?game;
            }
        };
        return null;
    };

    func heartbeat() {
        Debug.print("Heartbeat: " # Nat.toText(games.size()) # " games");
    };
}
