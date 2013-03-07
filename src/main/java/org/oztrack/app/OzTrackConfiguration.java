package org.oztrack.app;

import java.util.Date;

public interface OzTrackConfiguration {
    String getBaseURL();
    String getGeoServerLocalUrl();
    String getDataSpaceURL();
    String getDataSpaceUsername();
    String getDataSpacePassword();
    String getDataDir();
    String getMailServerHostName();
    Integer getMailServerPort();
    String getMailFromName();
    String getMailFromEmail();
    Integer getPasswordResetExpiryDays();
    boolean isAafEnabled();
    boolean isDataLicencingEnabled();
    String getRecaptchaPublicKey();
    String getRecaptchaPrivateKey();
    Date getClosedAccessDisableDate();
}