package controllers;

import java.util.List;
import models.Gebruiker;
import models.berichtsysteem.Bericht;
import play.data.validation.Required;

public class Berichten extends Application {

    public static void nieuwBericht() {
        render();
    }

    public static void berichten() {
        render();
    }

    /**
     * Het maken van een bericht
     * @param receiverInt De userID van de ontvanger
     * @param title De titel van het bericht
     * @param content De inhoud van het bericht
     */
    public static void berichtSturen(@Required(message = "Ontvanger ontbreekt") Long receiverInt, String title,
            @Required(message = "Inhoud ontbreekt") String content) {
        Gebruiker receiver = null;

        if (receiverInt == null || title.equals("") || content.equals("")) {
            renderText("Voer alle velden in");
        } else {
            receiver = Gebruiker.findById(receiverInt);
        }
        if (receiver == null) {
            renderText("Persoon bestaat niet");
        } else {
            try {
                Gebruiker Sender = (Gebruiker) renderArgs.get("connected");
                new Bericht(Sender, receiver, title, content);
                renderText("Bericht is verzonden");
            } catch (Exception e) {
            }
        }
    }

    /**
     * Het laden van een bericht
     * @param id ID van het bericht
     */
    public static void bericht(Long id) {
        Bericht b = Bericht.findById(id);
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        if (b.Receiver.equals(gebruiker) || b.Sender.equals(gebruiker)) {
            b.isRead = true;
            b.save();
            render(b);
        } else {
            flash.error("U heeft geen rechten om dit bericht in te zien.");
            inbox();
        }
    }

    /**
     * Een bericht verwijderen
     * @param id ID van het bericht
     */
    public static void deleteBericht(Long id) {
        Bericht b = Bericht.findById(id);
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        if (b.Receiver.equals(gebruiker) || b.Sender.equals(gebruiker)) {
            if (gebruiker.equals(b.Receiver)) {
                b.deletedReceipient = true;
            }
            if (gebruiker.equals(b.Sender)) {
                b.deletedSender = true;
            } else {
                flash.error("U heeft geen rechten om dit bericht te verwijderen.");
                Application.dashboard();
            }
            b.save();
            Application.dashboard();
        } else {
            flash.error("U heeft geen rechten om dit bericht te verwijderen.");
            Application.dashboard();
        }
    }

    /**
     * De inbox van de gebruiker
     */
    public static void inbox() {
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        //notFoundIfNull(gebruiker);
        List<Bericht> berichten = Bericht.find("Receiver", gebruiker).all();
        render(gebruiker, berichten);
    }

    /**
     * De outbox van de gebruiker
     */
    public static void outbox() {
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        notFoundIfNull(gebruiker);
        List<Bericht> berichten = Bericht.find("Sender", gebruiker).all();
        render(gebruiker, berichten);
    }
}
