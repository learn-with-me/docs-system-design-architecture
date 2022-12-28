# Design Email System

design an email sending system:

how can you guarantee the emails are sent to recipents.
Even in the case of server failures, it should send them when server come back up.
How would you guys design it? Message Queue with acknowledgements?

It would be best to understand how IMAP and POP3 work to answer this effectively, I believe. These are very mature protocols which probably address a lot of issues out of the box. SMTP for message delivery, POP/IMAP for message fetch/store. MEssage Transfer Agent (MTA) servers are based around queues for different senders, and messages are stored and forwarded as and when they come. For server failues just have replica servers, nothing else.
