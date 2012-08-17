package controllers;

import java.util.ArrayList;
import java.util.List;
import models.*;
import play.*;
import play.mvc.*;
import notifiers.*;
import play.data.validation.*;
import play.libs.*;
import play.cache.*;
import models.Gebruiker;
import models.berichtsysteem.Bericht;
import play.libs.OpenID;
import play.libs.OpenID.UserInfo;

public class Application extends Controller {

    public static List<Gebruiker> onlineUsers = new ArrayList<Gebruiker>();

    public static void index() {
        render();
    }

    public static void overhenk() {
        render();
    }

    public static void privacy() {
        render();
    }

    public static void admin() {
        render();
    }

    @Before
    static void globals() {
        renderArgs.put("onlineGebruikers", onlineUsers);
        renderArgs.put("connected", connectedUser());
        renderArgs.put("counter", userMessages());
    }

    /**
     * Deze methode zorgt ervoor dat je met een OpenID kan inloggen
     * Als je voor het eerst inlogt wordt er automatisch een gebruiker voor je aangemaakt
     * die je koppelt aan je OpenID
     */
    public static void authenticateOpenID() {
        Gebruiker gebruiker = null;
        if (OpenID.isAuthenticationResponse()) {
            // Retrieve the verified id
            UserInfo verifiedUser = OpenID.getVerifiedID();
            if (verifiedUser == null) {
                flash.put("error", "Oops. Authentication has failed");
                index();
            }
            else {
                String OpenID = verifiedUser.id;
                String email = verifiedUser.extensions.get("email");
                String[] nameArray = email.split("@");
                String name = nameArray[0];
                try {
                    gebruiker = Gebruiker.findByEmail(email);
                    if (!gebruiker.equals(null)) {
                        Logger.info("Application.java - User found email: " + email + " naam: " + name + " OpenID: " + OpenID);
                    }
                }
                catch (Exception e) {
                }
                if (gebruiker == null) {                     // if not exitsts, make new user.
                    Logger.info("Application.java - New openID user, registering in db.");
                    gebruiker = new Gebruiker(email, name);
                }
                connect(gebruiker);
                onlineUsers.add(gebruiker);
                flash.success("Welkom terug %s !", gebruiker.naam);
                Gebruikers.show(gebruiker.id);
                index();
            }
        }
        else {
            // Verify the id
            if (!OpenID.id("https://www.google.com/accounts/o8/id").required("email",
                    "http://axschema.org/contact/email").verify()) {
                flash.put("error", "Oops. Cannot contact google");
                index();
            }
        }
    }

    /**
     * Logt de gebruiker uit
     */
    public static void logout() {
        Gebruiker gebruiker = connectedUser();
        flash.success("Je bent uitgelogd");
        session.clear();
        onlineUsers.remove(gebruiker);
        home();
    }

    /**
     * Zet de gebruiker in de sessie
     * @param gebruiker Het object gebruiker wordt in de sessie gezet (id en naam)
     */
    static void connect(Gebruiker gebruiker) {
        session.put("logged", gebruiker.id);
        session.put("online", gebruiker.naam);
    }

    /**
     * Zet het ID van de gebruiker in de sessie
     * @return ID van de gebruiker
     */
    static Gebruiker connectedUser() {
        String gebruikerId = session.get("logged");
        return gebruikerId == null ? null : (Gebruiker) Gebruiker.findById(Long.parseLong(gebruikerId));
    }

    /**
     * Zet de naam van de gebruiker in de sessie
     * @return Naam van de gebruiker
     */
    static Gebruiker connectedUserNaam() {
        String gebruikerNaam = session.get("online");
        return gebruikerNaam == null ? null : (Gebruiker) Gebruiker.findByNaam(gebruikerNaam);
    }

    /**
     * Contact formulier verzenden
     * @param naam naam van de gebruiker
     * @param email email van de gebruiker
     * @param onderwerp desbetreffende onderwerp
     * @param bericht de inhoud van het bericht
     * @param code de gegenereerde captcha code
     * @param randomID
     */
    public static void postContact(@Required(message = "Naam is verplicht") String naam,
            @Required(message = "Email is verplicht") String email,
            @Required(message = "Onderwerp is verplicht") String onderwerp,
            @Required(message = "Bericht moet gevuld zijn") String bericht,
            @Required(message = "Voer de code in") String code, String randomID) {
        validation.equals(
                code, Cache.get(randomID)).message("Foutieve code, vul opnieuw in");
        if (validation.hasErrors()) {
            validation.keep();
            params.flash();
            flash.error("Fouten in het formulier");
            contact(naam, email, onderwerp, bericht, randomID);
        }

        try {
            if (Notifier.verstuurBericht(naam, email, onderwerp)) {
                flash.success("Je bericht is verzonden");
                flash.put("email", email);
                index();
            }
        }
        catch (Exception e) {
            Logger.error(e, "Application.java - Mail.error");
        }
    }

    /**
     * Methode om de captcha voor het contactformulier te genereren
     * @param id Gegenereerde ID voor de captcha
     */
    public static void captcha(String id) {
        Images.Captcha captcha = Images.captcha();
        String code = captcha.getText("#E4EAFD");
        Cache.set(id, code, "10mn");
        renderBinary(captcha);
    }

    public static void home() {
        render();
    }

    public static void indexen() {
        List indexen = Index.findAll();
        render(indexen);
    }

    public static void dashboard() {
        render();
    }

    public static void openid() {
        render();
    }

    public static void tutorial() {
        render();
    }

    public static void contacten() {
        render();
    }

    public static void contactToevoegen() {
        render();
    }

    public static void contactlijst() {
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        List<Gebruiker> contacten = gebruiker.contacten;
        render(contacten);
    }

    public static void contact(String id, String naam, String email, String onderwerp, String bericht) {
        String randomID = Codec.UUID();
        render(naam, email, onderwerp, bericht, randomID);
    }

    public static void parsers() {
        render();
    }

    public static void uwparsers() {
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        List<Parser> parsers = new ArrayList<Parser>();
        if(gebruiker.parsers != null){
            parsers = gebruiker.parsers;
        }
        render(parsers);
    }

    /**
     * Aantal ongelezen berichten die de gebruiker in zijn inbox heeft
     * @return Het aantal ongelezen berichten
     */
    public static int userMessages() {
        Gebruiker gebruiker = (Gebruiker) renderArgs.get("connected");
        List<Bericht> berichten = Bericht.find("Receiver", gebruiker).all();

        int counter = 0;
        for (Bericht b : berichten) {
            if (!b.isRead && !b.deletedReceipient) {
                counter++;
            }
        }
        return counter;
    }
}