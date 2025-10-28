// functions/index.js
require("dotenv").config();
const functions = require("firebase-functions");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  const {currency} = data;

  console.log("Received data:", data);

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 5000, // Hardcoded $50.00
      currency: currency || "usd",
    });

    console.log("Payment Intent created:", paymentIntent.id);
    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error("Stripe error details:", error.message, "Code:",
        error.code, "Param:", error.param);
    throw new functions.https.HttpsError("unknown", error.message);
  }
});
