/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Board {
    public Board() {

    }
    global Id boardId;
    global Integer parentId;
    global Id gameid;
    global Integer level;
    global List<Line> fundamental;
    global List<Line> stockPail;
    global List<Line> runnignTrack;
}
