Watch out, SAP.

### Changes: 

* Order should have
  * a "comments" text section
  * a drawing attached
  * a quantity attached

### Model logic

Users use the site. They can have many orders, for each part or group of parts they want made. Each order can have many dialogues, which represents the communication between the user and the supplier. Each dialogue has one supplier and, through orders, one user. Suppliers, however, can have many dialogues. Finally, both users and suppliers have addresses.