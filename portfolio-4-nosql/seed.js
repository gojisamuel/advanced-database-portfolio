// Run: mongosh paywise_nosql seed.js
db.transaction_events.drop();
db.customer_profiles.drop();

const channels = ["MOBILE_APP", "USSD", "WEB", "POS"];
const cities = ["Lagos", "Abuja", "Port Harcourt", "Kano", "Ibadan"];
const events = [];
for (let i = 1; i <= 50000; i++) {
  const amount = Math.round((100 + Math.random() * 50000) * 100) / 100;
  events.push({
    reference: "REF-" + i,
    from_account: 1 + Math.floor(Math.random() * 2000),
    to_account: 1 + Math.floor(Math.random() * 2000),
    amount: amount,
    status: ["SUCCESS", "SUCCESS", "SUCCESS", "FAILED"][Math.floor(Math.random() * 4)],
    created_at: new Date(Date.now() - Math.random() * 90 * 86400000),
    device: { channel: channels[Math.floor(Math.random() * 4)], os: "Android", ip: "10.0." + (i % 255) + "." + (i % 200) },
    geo: { city: cities[Math.floor(Math.random() * 5)], country: "NG" },
    fraud_flags: amount > 45000 ? ["HIGH_VALUE"] : [],
    metadata: { narration: "Payment " + i }
  });
}
db.transaction_events.insertMany(events);

db.customer_profiles.insertMany([
  { customer_id: 1, full_name: "Customer 1", kyc_status: "VERIFIED",
    preferences: { notifications: { sms: true, email: false }, language: "en" },
    beneficiaries: [{ name: "Ada", account_number: "0000000042" }, { name: "Tunde", account_number: "0000000099" }] },
  { customer_id: 2, full_name: "Customer 2", kyc_status: "PENDING",
    preferences: { notifications: { sms: true, email: true }, language: "en" }, beneficiaries: [] }
]);

db.transaction_events.createIndex({ from_account: 1, created_at: -1 });
db.transaction_events.createIndex({ reference: 1 }, { unique: true });
db.transaction_events.createIndex({ "geo.city": 1, created_at: -1 });
print("Seeded " + db.transaction_events.countDocuments() + " events");
