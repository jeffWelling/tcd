Currently, I suspect aggregation done manually in IRB while the daemon is running actively trying to poll, store, and aggregate the results can result in skewed statistics.  This is unconfirmed. 
