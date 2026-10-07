// 1. Latest 10 events for an account
db.transaction_events.find({ from_account: 123 }).sort({ created_at: -1 }).limit(10);

// 2. Fraud review queue: high-value failed or flagged events in the last 7 days
db.transaction_events.find({
  fraud_flags: "HIGH_VALUE",
  created_at: { $gte: new Date(Date.now() - 7 * 86400000) }
}).limit(20);

// 3. Aggregation: volume and count per city and channel
db.transaction_events.aggregate([
  { $match: { status: "SUCCESS" } },
  { $group: { _id: { city: "$geo.city", channel: "$device.channel" },
              total: { $sum: "$amount" }, count: { $sum: 1 } } },
  { $sort: { total: -1 } }, { $limit: 10 }
]);

// 4. Update a nested field (add a fraud flag)
db.transaction_events.updateOne({ reference: "REF-1" }, { $addToSet: { fraud_flags: "MANUAL_REVIEW" } });

// 5. Explain: confirm index use
db.transaction_events.find({ from_account: 123 }).sort({ created_at: -1 }).explain("executionStats");
