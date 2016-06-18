## Bowling Scores

A simple implemetation of Bowling scores system.

References rules are from [bowling2u.com/trivia/game/scoring.asp](http://bowling2u.com/trivia/game/scoring.asp)

### Docs

* create game with up to 5 players.
* input of frame has validations.
* player can input their rolls multiple times, the score up to current frame will be displayed.
* for strike/spare, if the bonus ball(s) is/are not rolled yet, score of the frame will displayed as `__`.
* after player finished, final score is displayed.
* after all players finished, game status/winner will be updated, and winner row wll be highted.

### Usage

1.	clone the repo

2. run bundle and migration

  ```
    bundle install && bundle exec rake db:migrate       
  ```  

3. start server

  ```
    bundle exec rails s
  ```

### Test

This example using Rspec

  ```
    bundle exec rspec spec   
  ```

### Demo

A demo can be found at [heroku](https://bowling-scores.herokuapp.com/)