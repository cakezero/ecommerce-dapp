# KIOSK

Kiosk is an e-commerce platform where users (merchants) lists their products for sale and a buyer can purchase the product with crypto/fiat but the merchant gets the funds sent directly to their wallet on successful delivery of the product.

## ABSTRACT

This project is aimed at facilitating a secure and automated transactions between users and merchants. It uses a smart contract to ensure that funds are securely held and only released upon product delivery. The contract serves as an intermediary, holding funds until the transaction is completed.

## KIOSK BREAKDOWN

- SMART CONTRACT

  * Merchant creation.

  * The contract holds funds sent from a user (buyer) who purchases a product from the platform.

  * The contract makes use of chainlink's Cross-Chain Interoperability Protocol (CCIP) to send the funds from the contract to the respective merchant wallet to their respective networks(ETH, MATIC, AVAX, ETC...).

  * The contract takes 0.1% commission fee from the merchant.

- BACKEND

  * The backend is used for authentication, delivery info (buyer), storing of the user product (merchant), creation of user profile(buyer and seller).
