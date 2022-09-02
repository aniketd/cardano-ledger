{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}

module Cardano.Ledger.Api.Tx.Out
  ( EraTxOut (..),

    -- * Shelley Era
    ShelleyTxOut,

    -- * Alonzo Era
    AlonzoTxOut,
    AlonzoEraTxOut (..),

    -- * Babbage
    BabbageTxOut,
    BabbageEraTxOut (..),
    setMinCoinTxOut,
    setMinCoinSizedTxOut,
  )
where

import Cardano.Ledger.Alonzo.TxBody (AlonzoEraTxOut (..), AlonzoTxOut)
import Cardano.Ledger.Babbage.TxBody (BabbageEraTxOut (..), BabbageTxOut)
import Cardano.Ledger.Core (EraTxOut (..), PParams, coinTxOutL)
import Cardano.Ledger.Serialization
import Cardano.Ledger.Shelley.TxBody (ShelleyTxOut)
import Lens.Micro

-- | Same as `setMinCoinSizedTxOut`, except it doesn't require the size of the
-- TxOut and will recompute it if needed. Initial amount is not important.
setMinCoinTxOut :: EraTxOut era => PParams era -> TxOut era -> TxOut era
setMinCoinTxOut pp = go
  where
    go txOut =
      let curMinCoin = getMinCoinTxOut pp txOut
          curCoin = txOut ^. coinTxOutL
       in if curCoin == curMinCoin
            then txOut
            else go (txOut & coinTxOutL .~ curMinCoin)

-- | This function will adjust the output's `Coin` value to the smallest amount
-- allowed by the UTXO rule. Initial amount is not important.
setMinCoinSizedTxOut ::
  EraTxOut era =>
  PParams era ->
  Sized (TxOut era) ->
  Sized (TxOut era)
setMinCoinSizedTxOut pp = go
  where
    go txOut =
      let curMinCoin = getMinCoinSizedTxOut pp txOut
          curCoin = txOut ^. toSizedL coinTxOutL
       in if curCoin == curMinCoin
            then txOut
            else go (txOut & toSizedL coinTxOutL .~ curMinCoin)