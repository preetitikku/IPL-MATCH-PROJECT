use iplpro;
select * from ball_by_ball order by Match_Id;
select * from batsman_scored order by Match_Id;
select * from extraa_runs order by Match_Id;
select * from wicket_taken order by Match_Id;

-- WHAT ARE THE TOP 5 PLAYERS WITH THE MOST MAN OF THE MATCH AWARDS? --
SELECT man_of_the_match, count(*) as awards_count
from matches
group by man_of_the_match
order by awards_count desc
limit 5;

-- print the caption of each team --
SELECT
    role_id AS team_captain,
    team_id AS team,
    MAX(player_id) AS player_name
FROM
    player_match
WHERE
    role_id = 1
GROUP BY
    team_id;
    
    -- print the captionkeeper of each team -- 
SELECT
    role_id AS team_captain_keepeer,
    team_id AS team,
    MAX(player_id) AS player_name
FROM
    player_match
WHERE
    role_id = 4
GROUP BY
    team_id;

-- HOW MANY MATCHES WERE WON BY EACH TEAM IN EACH SEASON ? --
select season_id,match_winner as team, count(*) as matches_won
from matches
group by season_id,match_winner
;
 
-- WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES ( FOURS AND SIXES COMBINED ) HIT IN EVERY MATCH ? --
select match_id,avg( case when runs_scored=4 or runs_scored=6 then 1 else 0 end )*100 as avg_boundaries
from batsman_scored
group by match_id; 

-- NAME OF THE YOUNGEST AND OLDEST PLAYER. --
select player_name , dob from iplpro.player order by dob asc limit 1 ;
select player_name , dob from iplpro.player order by dob desc limit 1 ;

-- MOST 4(FOURS) --
select v.Venue_Name,  
sum(case when(b.Runs_Scored=4) then 1 else 0 end) Fours,
count(distinct m.Match_Id) Matches,
sum(case when(b.Runs_Scored=4) then 1 else 0 end)/count(distinct m.Match_Id) Fours_Per_Match
from iplpro.Batsman_Scored b 
inner join iplpro.matches m on b.Match_Id=m.Match_Id
inner join iplpro.vvenue v on v.Venue_Id=m.Venue_Id
group by v.Venue_Name
order by 2 desc ;

-- most 6 (SIXES) --
select v.Venue_Name, 
 sum(case when(Runs_Scored=6) then 1 else 0 end) Sixes,count(distinct m.Match_Id) Matches
 ,sum(case when(Runs_Scored=6) then 1 else 0 end)/count(distinct m.Match_Id) Sixes_Per_Match
from iplpro.Batsman_Scored b 
inner join iplpro.matches m on b.Match_Id=m.Match_Id
inner join iplpro.vvenue v on v.Venue_Id=m.Venue_Id
group by v.Venue_Name
order by 2 desc;


-- HIGHEST SCORER --
SELECT a.Match_Id, c.Player_Name, e.Season_Year, SUM(b.Runs_Scored) AS RunsScored
FROM iplpro.Ball_by_Ball a 
INNER JOIN iplpro.Batsman_Scored b ON CONCAT(a.Match_Id, a.Over_Id, a.Ball_Id, a.Innings_No) = CONCAT(b.Match_Id, b.Over_Id, b.Ball_Id, b.Innings_No)
INNER JOIN iplpro.Player c ON a.Striker = c.Player_Id 
INNER JOIN iplpro.Matches d ON a.Match_Id = d.Match_Id 
INNER JOIN iplpro.Season e ON d.Season_Id = e.Season_Id
GROUP BY a.Match_Id, c.Player_Name, e.Season_Year
ORDER BY RunsScored DESC;

-- TOTAL RUNS BY HITTING BOUNDARIES --
SELECT a.season_year,
       a.Fours,
       a.Sixes,
       SUM(a.Fours * 4 + a.Sixes * 6) AS total_runs_in_boundaries 
FROM (
    SELECT season.season_year, 
           SUM(CASE WHEN batsman_scored.runs_scored = 4 THEN 1 ELSE 0 END) AS 'Fours', 
           SUM(CASE WHEN batsman_scored.runs_scored = 6 THEN 1 ELSE 0 END) AS 'Sixes'
    FROM iplpro.matches
         INNER JOIN iplpro.season ON matches.season_id = season.season_id 
         INNER JOIN iplpro.batsman_scored ON batsman_scored.match_id = matches.match_id 
    GROUP BY season.season_year
) a
GROUP BY a.season_year, a.Fours, a.Sixes;

-- what is the number of matches won by each team batting first versus batting second -- 
with cteteam_wins as(
SELECT
    matches.match_id,
    matches.match_winner,
    ball_by_ball.Team_Batting,
    ball_by_ball.team_bowling
FROM
    matches
LEFT JOIN
    ball_by_ball ON matches.Match_Id = ball_by_ball.Match_Id
GROUP BY
    matches.match_id, matches.match_winner, ball_by_ball.Team_Batting, ball_by_ball.team_bowling
)
SELECT
    team_batting AS team,
    COUNT(CASE WHEN match_winner = team_batting THEN 1 END) AS wins_batting_first,
    COUNT(CASE WHEN match_winner = team_bowling THEN 1 END) AS wins_batting_second
FROM
    cteteam_wins
GROUP BY
    team_batting, team_batting;
    
    -- TOTAL MAN OF THE MATCH
 SELECT
    man_of_the_match,
    COUNT(*) AS total_awards
FROM
    matches
GROUP BY
    man_of_the_match
LIMIT 0, 1000;

-- which team most win the toss in each season --
    SELECT
    season_id,
   toss_winner,
    COUNT(*) AS toss_wins
FROM
    matches
GROUP BY
    season_id, toss_winner;

-- print the table that have winner of the season with venue , match_date , win_type for each season -- 
SELECT
    m.season_id,
    m.match_winner,
    m.venue_id,
    m.match_date,
    m.win_type
FROM
    matches m
JOIN
    (
        SELECT
            season_id,
            MAX(match_date) AS latest_match_date
        FROM
            matches
        GROUP BY
            season_id
    ) latest_matches ON m.season_id = latest_matches.season_id
                     AND m.match_date = latest_matches.latest_match_date;