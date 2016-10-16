DROP VIEW IF EXISTS q1a, q1b, q1c, q1d, q2, q3, q4, q5, q6, q7;
DROP VIEW IF EXISTS obama_committee_contributors;
DROP VIEW IF EXISTS obama;
DROP VIEW IF EXISTS candidates_with_committee_contribution;
DROP VIEW IF EXISTS committee_count;
DROP VIEW IF EXISTS contributions_from_org;

-- Question 1a
CREATE VIEW q1a(id, amount)
AS
  SELECT cmte_id, transaction_amt
  FROM committee_contributions
  WHERE transaction_amt > 5000
;

-- Question 1b
CREATE VIEW q1b(id, name, amount)
AS
  SELECT cmte_id, name, transaction_amt
  FROM committee_contributions
  WHERE transaction_amt > 5000
;

-- Question 1c
CREATE VIEW q1c(id, name, avg_amount)
AS
  SELECT id, name, AVG(amount)
  FROM q1b
  GROUP BY id, name
;

-- Question 1d
CREATE VIEW q1d(id, name, avg_amount)
AS
  SELECT id, name, avg_amount
  FROM q1c
  WHERE avg_amount > 10000
;

-- Question 2
CREATE VIEW q2(from_name, to_name)
AS
  SELECT c.name AS from_name, c2.name AS to_name
  FROM intercommittee_transactions AS ic
  JOIN committees AS c
  ON ic.other_id = c.id
  JOIN committees AS c2
  ON ic.cmte_id = c2.id
  WHERE c.pty_affiliation = 'DEM' AND c2.pty_affiliation = 'DEM'
  GROUP BY c.id, c2.id
  ORDER BY COUNT(*) DESC
  LIMIT 10
;

-- Question 3

CREATE VIEW obama(id)
AS
  SELECT id
  FROM candidates
  WHERE name = 'OBAMA, BARACK'
;


CREATE VIEW obama_committee_contributors(id)
AS
  SELECT DISTINCT cmte_id
  FROM committee_contributions cc
  JOIN obama o
  ON o.id = cc.cand_id
;

CREATE VIEW q3(name)
AS
  SELECT name
  FROM (SELECT id FROM committees EXCEPT SELECT id FROM obama_committee_contributors) nc
  JOIN committees c
  ON nc.id = c.id
;

-- Question 4.
CREATE VIEW committee_count(c)
AS
  SELECT COUNT(*)
  FROM committees
;

CREATE VIEW candidates_with_committee_contribution(id, c)
AS
  SELECT cand_id, COUNT(DISTINCT cmte_id)
  FROM committee_contributions
  GROUP BY cand_id
;

CREATE VIEW q4 (name)
AS
  SELECT c.name
  FROM candidates_with_committee_contribution ccc
  JOIN candidates c
  ON ccc.id = c.id
  JOIN committee_count cc
  ON ccc.c > cc.c / 100
;

-- Question 5
CREATE VIEW contributions_from_org(id, total)
AS
  SELECT cmte_id, SUM(transaction_amt)
  FROM individual_contributions
  WHERE entity_tp = 'ORG'
  GROUP BY cmte_id
;

CREATE VIEW q5 (name, total_pac_donations)
AS
  SELECT c.name, co.total
  FROM committees c
  LEFT OUTER JOIN contributions_from_org co
  ON c.id = co.id
;

-- Question 6
CREATE VIEW q6 (id) AS
  SELECT DISTINCT cand_id
  FROM committee_contributions
  WHERE entity_tp = 'PAC' AND cand_id IS NOT NULL
  INTERSECT
    (SELECT DISTINCT cand_id
    FROM committee_contributions
    WHERE entity_tp = 'CCM' AND cand_id IS NOT NULL)
;

-- Question 7
CREATE VIEW q7 (cand_name1, cand_name2) AS
  SELECT 1,1 -- replace this line
;
