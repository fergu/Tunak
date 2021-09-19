/*
 *  Constants.h
 *  Tunak
 *
 *  Created by Kevin Ferguson on 9/2/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

//Value Definitions
#define TK_ROUND_LENGTH 15.0f //Seconds
#define TK_UPDATE_INTERVAL 0.5 //Seconds
#define TK_ROUND_COUNTDOWN_TIME 3 //Seconds

#define TK_ROUNDS_MAX 10 //Rounds
#define TK_MAX_ROUND_SCORE 1000 //Points

#define TK_SCORE_INCREMENT (TK_MAX_ROUND_SCORE*TK_UPDATE_INTERVAL)/(TK_ROUND_LENGTH)


//Status Definitions
#define TK_STATUS_LOADING 00
#define TK_STATUS_READY 100
#define TK_STATUS_COUNTDOWN 01
#define TK_STATUS_PLAYING 02
#define TK_STATUS_CORRECTANSWER 03
#define TK_STATUS_WRONGANSWER 04
#define TK_STATUS_NOANSWER 05
#define TK_STATUS_PAUSED 06
#define TK_STATUS_GAMEOVER 07
#define TK_STATUS_PREPARED 10
#define TK_STATUS_SUSPENDED 1000

//Mode Definitions
#define TK_MODE_POINTS 10
#define TK_MODE_ACCURACY 11
#define TK_MODE_ENDURANCE 12