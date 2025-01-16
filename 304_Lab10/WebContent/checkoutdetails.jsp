<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout Details</title>
</head>
<body>

<h1>Checkout</h1>
<%
    getConnection(); // Assumes getConnection() is defined in jdbc.jsp and initializes 'con'
    String custId = request.getParameter("customerId");
    Statement stmt = con.createStatement(); 
	stmt.execute("USE orders");
%>
<form method="get" action="order.jsp">
<table>
<tr><td>Customer ID:</td><td><input type="hidden" name="customerId" value="<%= custId %>"></td></tr>
<tr><td>Password:</td><td><input type="hidden" name="password" value="<%= request.getParameter("password") %>"></td></tr>
<tr><td><h2>Address:</h2></td></tr>
<%
    String ader = "SELECT address, city, state, postalCode, country FROM customer WHERE customerId = ?";
    String paym = "SELECT paymentType, paymentNumber, paymentExpiryDate FROM paymentMethod WHERE customerId = ?";
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        pstmt = con.prepareStatement(ader);
        pstmt.setString(1, custId);
        rs = pstmt.executeQuery();

        // Declare 'value' once here to avoid duplicates
        String value = null;

        if (rs.next()) {
            value = rs.getString("address");
            out.print("<tr><td><label for=\"address\">Address:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"address\" name=\"address\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"address\" name=\"address\" required></td></tr>");
            }

            value = rs.getString("city");
            out.print("<tr><td><label for=\"city\">City:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"city\" name=\"city\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"city\" name=\"city\" required></td></tr>");
            }

            value = rs.getString("state");
            out.print("<tr><td><label for=\"state\">State:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"state\" name=\"state\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"state\" name=\"state\" required></td></tr>");
            }

            value = rs.getString("postalCode");
            out.print("<tr><td><label for=\"postalCode\">Postal Code:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"postalCode\" name=\"postalCode\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"postalCode\" name=\"postalCode\" required></td></tr>");
            }

            value = rs.getString("country");
            out.print("<tr><td><label for=\"country\">Country:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"country\" name=\"country\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"country\" name=\"country\" required></td></tr>");
            }

        } else {
            // If no address found for this customer, require manual input
%>
<tr><td><label for="address">Address:</label></td></tr>
<tr><td><input type="text" id="address" name="address" required></td></tr>
<tr><td><label for="city">City:</label></td></tr>
<tr><td><input type="text" id="city" name="city" required></td></tr>
<tr><td><label for="state">State:</label></td></tr>
<tr><td><input type="text" id="state" name="state" required></td></tr>
<tr><td><label for="postalCode">Postal Code:</label></td></tr>
<tr><td><input type="text" id="postalCode" name="postalCode" required></td></tr>
<tr><td><label for="country">Country:</label></td></tr>
<tr><td><input type="text" id="country" name="country" required></td></tr>
<%
        }

        out.print("<tr><td><h2>Payment Method:</h2></td></tr>");

        pstmt = con.prepareStatement(paym);
        pstmt.setString(1, custId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            value = rs.getString("paymentType");
            out.print("<tr><td><label for=\"paymentType\">Payment Type:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"paymentType\" name=\"paymentType\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"paymentType\" name=\"paymentType\" required></td></tr>");
            }

            value = rs.getString("paymentNumber");
            out.print("<tr><td><label for=\"paymentNumber\">Payment Number:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"text\" id=\"paymentNumber\" name=\"paymentNumber\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"text\" id=\"paymentNumber\" name=\"paymentNumber\" required></td></tr>");
            }

            java.sql.Date sqlDate = rs.getDate("paymentExpiryDate");
            value = "";
            if (sqlDate != null) {
                // Convert java.sql.Date to LocalDate (Java 8+)
                LocalDate localDate = sqlDate.toLocalDate();
                value = localDate.toString();
            }

            out.print("<tr><td><label for=\"paymentExpiryDate\">Payment Expiry Date:</label></td></tr>");
            if (value != null && !value.isEmpty()) {
                out.print("<tr><td><input type=\"date\" id=\"paymentExpiryDate\" name=\"paymentExpiryDate\" value=\"" + value + "\" readonly></td></tr>");
            } else {
                out.print("<tr><td><input type=\"date\" id=\"paymentExpiryDate\" name=\"paymentExpiryDate\" required></td></tr>");
            }

        } else {
            // If no payment method found, require manual input
%>
<tr><td><label for="paymentType">Payment Type:</label></td></tr>
<tr><td><input type="text" id="paymentType" name="paymentType" required></td></tr>
<tr><td><label for="paymentNumber">Payment Number:</label></td></tr>
<tr><td><input type="text" id="paymentNumber" name="paymentNumber" required></td></tr>
<tr><td><label for="paymentExpiryDate">Payment Expiry Date:</label></td></tr>
<tr><td><input type="date" id="paymentExpiryDate" name="paymentExpiryDate" required></td></tr>
<%
        }
    } catch (SQLException e) {
        out.println("Database error: " + e.getMessage());
    }
%>

<tr><td><input type="submit" value="Submit"></td><td><input type="reset" value="Reset"></td></tr>
</table>
</form>

</body>
</html>
