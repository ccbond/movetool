module movetool::coin {
    use std::vector;

    use sui::coin::{Self, Coin};
    use sui::tx_context::TxContext;

    const EInsufficientCoins: u64 = 0;

    public fun merge_and_split_coin<CoinType>(
        coins: vector<Coin<CoinType>>,
        split_quantity: u64,
        ctx: &mut TxContext,
    ): (Coin<CoinType>, Coin<CoinType>) {
        let len = vector::length(&coins);
        let master_coin = vector::pop_back(&mut coins);
        let i = 1;
        while({
            spec {
                invariant  i <= len;
            };
            i < len
        }) {
            let sub_coin = vector::pop_back(&mut coins);
            coin::join(&mut master_coin, sub_coin);
            i = i + 1;
        };

        vector::destroy_empty(coins);

        assert!(coin::value(&master_coin) > split_quantity, EInsufficientCoins);

        let split_coin = coin::split(&mut master_coin, split_quantity, ctx);
        (master_coin, split_coin)
    }
}