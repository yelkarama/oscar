<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@page import="com.auth0.jwt.exceptions.SignatureVerificationException"%>
<%@page import="java.security.PublicKey"%>
<%@page import="org.bouncycastle.cert.jcajce.JcaX509CertificateConverter"%>
<%@page import="org.bouncycastle.cert.X509CertificateHolder"%>
<%@page import="java.io.StringReader"%>
<%@page import="org.bouncycastle.openssl.PEMParser"%>
<%@page import="org.bouncycastle.util.io.pem.PemReader"%>
<%@page import="java.io.IOException"%>
<%@page import="java.security.cert.CertificateException"%>
<%@page import="java.security.cert.X509Certificate"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.io.ByteArrayInputStream"%>
<%@page import="java.security.cert.CertificateFactory"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="java.security.SecureRandom"%>
<%@page import="org.apache.commons.codec.binary.Hex"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="javax.crypto.Mac"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="com.auth0.jwt.interfaces.DecodedJWT"%>
<%@page import="org.oscarehr.util.PKCEUtils"%>
<%@page import="oscar.OscarProperties"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="org.apache.cxf.jaxrs.client.WebClient"%>
<%@page import="java.security.interfaces.RSAPrivateKey"%>
<%@page import="java.security.interfaces.RSAPublicKey"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Date"%>
<%@page import="com.auth0.jwt.JWT"%>
<%@page import="java.security.cert.Certificate"%>
<%@page import="java.security.PrivateKey"%>
<%@page import="java.security.Key"%>
<%@page import="java.security.KeyStore"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.auth0.jwt.algorithms.Algorithm"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.auth0.jwt.JWTCreator"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.apache.log4j.Logger"%>
<%@page import="org.oscarehr.util.MiscUtils"%>

<%
	Logger logger = MiscUtils.getLogger();


	String toolbar = request.getParameter("toolbar");
	String iss = request.getParameter("iss");
	String state = request.getParameter("state");
	String clientId = request.getParameter("client_id");
	String code = request.getParameter("code");

	if(StringUtils.isEmpty(code)) {
		//redirect to login page with error;
		logger.warn("no code returned from authorize call!");
		response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("No code received from eHealth", "UTF-8" ));
		return;
	}
	
	logger.debug("code = "  + code);
	
	//load up our verifier for this call
	String codeVerifier = (String)session.getAttribute("eho_verifier-" + state);	
	Boolean alreadyLoggedIn = (Boolean)session.getAttribute("eho_verifier-" + state + ".alreadyLoggedIn");
	
	if(codeVerifier == null) {
		logger.warn("no code verifier found for this state (" + state  + ")");
		response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("No matching code verifier found in system", "UTF-8" ));
		return;
	}
	
	String authorizeUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.authorizeUrl");
	String tokenUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.tokenUrl");
	String audUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.audUrl");
	
	String audUrl1 = OscarProperties.getInstance().getProperty("oneid.oauth2.audUrl1");
	String callbackUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.callbackUrl");
	
	Date expiryDate = PKCEUtils.getDateInFuture(10);
	
	Map<String, String> params = new HashMap<>();
	params.put("grant_type", "authorization_code");
	//TODO: Not sure that _profile should be hard coded
	params.put("_profile", "http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Immunization");
	params.put("client_assertion_type", "urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer");

	params.put("code", code);
	params.put("redirect_uri", callbackUrl);
	params.put("client_id", clientId);

	params.put("code_verifier",codeVerifier);
	
	String keystoreFile = OscarProperties.getInstance().getProperty("oneid.oauth2.keystore");
	String keystorePassword = OscarProperties.getInstance().getProperty("oneid.oauth2.keystore.password");
	String keystoreAlias = OscarProperties.getInstance().getProperty("oneid.oauth2.keystore.alias");
	
	FileInputStream is  = new FileInputStream(keystoreFile);

	KeyStore keystore = KeyStore.getInstance(KeyStore.getDefaultType());
	keystore.load(is, keystorePassword.toCharArray());
	Key key = keystore.getKey(keystoreAlias, keystorePassword.toCharArray());
	    
    if (key instanceof PrivateKey) {
    	Certificate cert = keystore.getCertificate(keystoreAlias);
    	
    	JWTCreator.Builder builder = JWT.create()
    			.withSubject(clientId)
    			.withAudience(audUrl)
    			.withExpiresAt(expiryDate)
    			.withIssuer(clientId);
    	
		String jwt = builder.sign(Algorithm.RSA256((RSAPublicKey)cert.getPublicKey(), (RSAPrivateKey) key));
    	params.put("client_assertion", jwt);
    }	    
			
	WebClient wc = WebClient.create(tokenUrl); 
	for (Entry<String, String> entry : params.entrySet()) {
		wc.query(entry.getKey(), entry.getValue());
	}

	Response response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post(null);
	
	logger.debug("status=" + response2.getStatus());
	
	if(response2.getStatus() != 200) {
		logger.warn("status from token endpoint is "  + response2.getStatus());
		String body = response2.readEntity(String.class);
		logger.warn(body);
		//need to redirect
		response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Received unexpected response from eHealth", "UTF-8" ));
		return;
	}
	
	String body = response2.readEntity(String.class);
	logger.debug(body);
	JSONObject jsonResponse = JSONObject.fromObject(body);

	boolean verify = Boolean.valueOf(OscarProperties.getInstance().getProperty("oneid.oauth2.verifyTokens","true"));
	
	String accessToken = jsonResponse.getString("access_token");
	DecodedJWT accessTokenJWT =  JWT.decode(accessToken);
	
	String idToken = jsonResponse.getString("id_token");
	DecodedJWT idTokenJWT =  JWT.decode(idToken);
	
	if(verify) {
		String algorithm = accessTokenJWT.getAlgorithm();
		String kid = accessTokenJWT.getKeyId();
		
		logger.debug("algorithm=" + algorithm);
		logger.debug("kid=" + kid);
		
		X509Certificate certToVerify = null;
		JSONArray certificateStr = getCertificate(algorithm,kid);
		if(certificateStr != null) {
			for(int x=0;x<certificateStr.size();x++) {
				String d = certificateStr.getString(x);
				d = "-----BEGIN CERTIFICATE-----\n" + d + "\n-----END CERTIFICATE-----";
			
				PEMParser parser = new PEMParser(new StringReader(d));
				X509CertificateHolder  holder = (X509CertificateHolder)parser.readObject();
				if(holder != null) {
					JcaX509CertificateConverter converter = new JcaX509CertificateConverter();
					certToVerify =  converter.getCertificate(holder);
				}
			}
		}
		
		Algorithm algorithm1 = null;
		if(certToVerify != null) {
			PublicKey publicKey =  certToVerify.getPublicKey();
			//TODO: this probably shouldn't be hardcoded to RSA256
			 algorithm1 = Algorithm.RSA256((RSAPublicKey)publicKey,null);
			 logger.debug("algorithm1="+algorithm);
		}
		
		if(algorithm1 == null) {
			response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Unable to verify tokens", "UTF-8" ));
			return;
		}
	
		try {
			algorithm1.verify(accessTokenJWT);
			algorithm1.verify(idTokenJWT);
			session.setAttribute("tokens",jsonResponse);
		}catch(SignatureVerificationException e) {
			response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Unable to verify tokens", "UTF-8" ));
			return;
		}

	} else {
		session.setAttribute("tokens",jsonResponse);
	}
	
	String subject = idTokenJWT.getSubject();
	String contextSessionId = idTokenJWT.getClaim("contextSessionId").asString();
	String email = idTokenJWT.getClaim("email").asString();
	String serviceEntitlementsEncoded = idTokenJWT.getClaim("serviceEntitlements").asString();
	String serviceEntitlements = new String( Base64.decodeBase64(serviceEntitlementsEncoded));
	
	JSONObject serviceEntitlementsJSON = JSONObject.fromObject(serviceEntitlements);
	
	
	if(alreadyLoggedIn != null && alreadyLoggedIn) {
		
		session.setAttribute("oneid_token",body);
		String forwardURL = (String)session.getAttribute("eho_verifier-" + state + ".forwardURL");	
		response.sendRedirect(forwardURL);
		return;
		
	} else {
		//TODO: Not sure what we can do with this ID token, 
		
		//{"UAO":[{"type":"Organization","id":"2.16.840.1.113883.3.239.9:103698089424","friendName":"Sinai Health System","service":[{"name":"DHDR","attribute":[{"name":"scope","value":"user/MedicationDispense.read;user/Consent.write"},{"name":"_profile","value":"http%3A%2F%2Fehealthontario.ca%2FStructureDefinition%2Fca-on-dhdr-profile-MedicationDispense"}]},{"name":"DHIR","attribute":[{"name":"scope","value":"user/Immunization.read;user/Immunization.write"},{"name":"_profile","value":"http%3A%2F%2Fehealthontario.ca%2FStructureDefinition%2Fca-on-dhir-profile-Immunization"}]},{"name":"DHIR","attribute":[{"name":"scope","value":"user/Patient.read"},{"name":"_profile","value":"http%3A%2F%2Fehealthontario.ca%2FStructureDefinition%2Fca-on-dhir-profile-Patient"}]}]}]}
		
		//the token - a new session will be created, so we pass it here
		String encryptedToken = null;
		String oneIdKey = OscarProperties.getInstance().getProperty("oneid.encryptionKey");
		try {
			 SecureRandom sr = new SecureRandom();
			 byte[] b = new byte[16];
			 sr.nextBytes(b);
			 sr.setSeed(b);
			 IvParameterSpec iv = new IvParameterSpec(b);
			 
			 SecretKeySpec secretKey = new SecretKeySpec(oneIdKey.getBytes("UTF-8"), "AES");
			 Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING");
			 cipher.init(Cipher.ENCRYPT_MODE, secretKey,iv);
			 byte[] encrypted = cipher.doFinal(body.getBytes());
			 encryptedToken =  java.util.Base64.getEncoder().encodeToString(encrypted) + ":" + Base64.encodeBase64String(b);	
		} catch (Exception ex) {		   	
			logger.error("Error",ex);	   
			response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Error generating encrypted token", "UTF-8" ));
		}
		
				
		long ts = new Date().getTime();
		//create signature
		String signature = null;
		try {
	   		Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
	   		SecretKeySpec secret_key = new SecretKeySpec(OscarProperties.getInstance().getProperty("oneid.encryptionKey").getBytes("UTF-8"), "HmacSHA256");
	   		sha256_HMAC.init(secret_key);
	   		signature = Hex.encodeHexString(sha256_HMAC.doFinal((subject + email + encryptedToken + ts).getBytes("UTF-8")));
		} catch(Exception e) {
	    	MiscUtils.getLogger().error("Error",e);
	    	response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Error signing parameters", "UTF-8" ));
		}
		
		logger.debug(accessToken);
		
		session.setAttribute("nameId",subject);
		session.setAttribute("email",email);
		session.setAttribute("encryptedOneIdToken",encryptedToken);
		session.setAttribute("ts",ts);
		session.setAttribute("signature",signature);
		session.setAttribute("oauth2","true");
		
		response.sendRedirect(request.getContextPath() + "/eho/loginForm.jsp");
	}
	
	
%>

<%!
JSONArray getCertificate(String algorithm , String kid) {
	
	WebClient wc = WebClient.create(OscarProperties.getInstance().getProperty("oneid.oauth2.certsUrl")); 
	Response response2 = wc.get();
	if(response2.getStatus() == 200) {
		String body = response2.readEntity(String.class);
		JSONObject obj = JSONObject.fromObject(body);
		JSONArray keys = obj.getJSONArray("keys");
		for(int x=0;x<keys.size();x++) {
			String jAlgorithm = keys.getJSONObject(x).getString("alg");
			String jKid = keys.getJSONObject(x).getString("kid");
			
			if(algorithm.equals(jAlgorithm) && kid.equals(jKid)) {
				return keys.getJSONObject(x).getJSONArray("x5c");
			}
			
		}
	}

	return null;
}

%>