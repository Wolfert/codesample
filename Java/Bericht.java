package models.berichtsysteem;

import java.util.Calendar;
import java.util.Date;
import javax.persistence.Entity;
import play.db.jpa.Model;
import models.Gebruiker;

/**
 *
 * @author Wolfert
 */
@Entity
public class Bericht extends Model {

    public Gebruiker Sender;
    public Gebruiker Receiver;
    public Date date;
    public boolean isRead;
    public String title;
    public String content;
    public boolean deletedReceipient = false;
    public boolean deletedSender = false;

    public Bericht(Gebruiker Sender, Gebruiker Receiver, String title, String content) {
        this.Sender = Sender;
        this.Receiver = Receiver;
        this.date = Calendar.getInstance().getTime();
        this.isRead = false;
        this.title = title;
        this.content = content;
        save();
    }
}
