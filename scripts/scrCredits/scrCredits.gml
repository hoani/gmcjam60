




function getCredits() {
    return [ 
        newCredit("", "Made for the GMC Jam 60"),
        newCredit("Design", "Hoani Bryson"),
        //newCredit("Sound Effects", "Levi Vilas Boas\nmOsh"),
        //newCredit("Music", "ELVGames"),
        newCredit("Fonts", "ChequeredInk"),
        newCredit("Special Thanks - GMC Jam Hosts", "Misu and Alice"),
        newCredit("Special Thanks - Scoreboat", "Magnus M."),
    ];
}


function Credits() constructor {
    cDuration = 160;
    cCooldown = 40;
    cTimer = 1;
    credits = getCredits()
    cIndex = -1;
    
    
    static Update = function() {
        if cTimer > 0 {
            cTimer--;
            
            if cTimer == 0 {
                if cIndex == -1 {
                    cIndex++
                    cTimer = cDuration;
                } else {
                    credits[cIndex].End()
                }
            }
        } else if cTimer <= 0 && credits[cIndex].IsDead() {
            cTimer--;
            if cTimer < -cCooldown {
                cIndex = (cIndex + 1) % array_length(credits);
                credits[cIndex].Restart();
                cTimer = cDuration;
            }
        }
        
        
        if cIndex >= 0 {
            credits[cIndex].Step();
        }
    }
    
    static Draw = function() {
        if cIndex >= 0 {
            credits[cIndex].Draw();
        }
    }
    
}



function newCredit(what, who) {
    cWhatBox = new Box(640, 8)
    cWhoBox = new Box(640, 64)
    return {
        cWhoBox: cWhoBox,
        cPadding: 32,
        cWhatBox: cWhatBox,
        what: NewText(what, fScrawlingPadSm, new FadeAppear(60, 6), new FadeOut(60)).WithFit(cWhatBox).WithAlign(fa_center),
        who: NewText(who, fScrawlingPad, new FadeAppear(60, 6), new FadeOut(60)).WithFit(cWhoBox).WithAlign(fa_center),
        IsDead: function() {
            return what.IsDead() && who.IsDead();
        },
        End: function() {
            what.End();
            who.End();
        },
        Restart: function() {
            what.Restart();
            who.Restart();
        },
        Step: function() {
            what.Step();
            who.Step()
        },
        Draw: function() {
            {
                var ypos = room_height - (cWhoBox.h + 2*cPadding + cWhatBox.h + cPadding);
                var xpos = (room_width - cWhoBox.w)/2
                what.Draw(xpos, ypos);
            }
            {
                var ypos = room_height - (cWhoBox.h + 2*cPadding);
                var xpos = (room_width - cWhoBox.w)/2
                who.Draw(xpos, ypos);
            }
        }
    }
}