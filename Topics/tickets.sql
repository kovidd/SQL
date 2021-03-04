-- Tickets
SELECT * FROM tickets;

-- Select tickets with no. between 00005432001000 and 00005432001050
SELECT *
FROM tickets
WHERE ticket_no BETWEEN '0005432001000' AND '0005432001050';