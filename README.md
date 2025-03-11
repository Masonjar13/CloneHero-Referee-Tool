# CloneHero Referee Tool
Simple app to keep track and build a text report when reffing in CloneHero tournaments.

Referees typically need to type everything out to keep track of the current match. Instead, this tool only requires that you type out the group letter and names of the players. If you want the players' seed included, use parenthesis in front of the player name (see screenshot below). Everything else is handled via drop-downs. There is also a button to save a screenshot to a designated match folder.

This is a universal tool, but follows CSC format standards.

# How to use
Download the [latest release](https://github.com/Masonjar13/CloneHero-Referee-Tool/releases/latest) and run it. A folder named "data" will be created, you can find the setlist file there. Another folder named "matches" will also be created.

Type in the player who will pick and ban first in the High Seed Player box and the other player in the Low Seed Player box. You can optionally add their seed numbers in these boxes (see screenshot below). Add a group letter if relevant.

Select the bans and picks from the drop-down lists as you go. At the score screen, be sure to click the Screenshot button to save a screenshot (at this time, you can not save in-game screenshots as a spectator). Screenshots will be saved to the Matches folder.

At any time, you can click the "Save to Clipboard" button to save all current data to your clipboard in a ready-to-post format. If you end up needing the data again, but you've closed the window, you can check the log file in the "data" folder.

# Setlist format
The setlists are saved in an ini file, which will be downloaded the first time you run the tool. You can find it in the data folder inside the folder the ref tool is in. You can update the file to the most current version by clicking the update button next to the setlist drop-down.

 **Tournament creators:** If you would like to add your setlist to the tool, please submit a pull request or contact me with your setlist in the correct ini format.

 The format of each setlist is as follows (see [setlists.ini](/data/setlists.ini) for working examples):

     [Setlist Name]
     01=Song 1`Solo
     02=Song 2`Strum
     03=Song 3`Hybrid
     04=Song 4`NA
     05=Song 5`HybridTB
Each song is required to have a type. The current available types are Solo, Strum, Hybrid, and NA or N/A. Each type (except NA) can be proceeded with TB to denote a song used for a tiebreaker. NA specifies no type and is intended for use without a tiebreaker, such as a Swiss-style format. In the event you want to use tiebreakers, but do not want specific types, use Hybrid/HybridTB for all songs.

![CH Ref Tool](https://i.imgur.com/tgU9Uc7.png)

# Limitations
Due to the very simple UI choice, on a 1080 monitor with no DPI scaling, a maximum of 20 songs can be added before running off the screen. Most tournaments are best of 7 or 9, so this isn't a real issue.

# License
MIT

