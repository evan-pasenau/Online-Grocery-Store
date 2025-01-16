<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Evan and Ian's Grocery Order Processing</title>
</head>
<style>
	/* General page styling */
	body {
		font-family: Arial, sans-serif;
		background-color: #f8f9fa;
		margin: 0;
		padding: 20px;
		color: #333;
	}

	h1 {
		color: #343a40;
		font-size: 2em;
		text-align: center;
		margin-bottom: 20px;
	}

	/* Table Styling */
	table {
		width: 100%;
		margin-bottom: 20px;
		border-collapse: collapse;
	}

	th, td {
		border: 1px solid #ddd;
		padding: 10px;
		text-align: left;
	}

	th {
		background-color: #f2f2f2;
		font-weight: bold;
	}

	.product-details th, .product-details td {
		background-color: #fff;
	}

	/* Button Styling */
	button {
		padding: 10px 20px;
		background-color: #007bff;
		color: white;
		border: none;
		border-radius: 5px;
		cursor: pointer;
		font-size: 1em;
	}

	button:hover {
		background-color: #0056b3;
	}

	/* Container for the form button */
	form {
		display: flex;
		justify-content: center;
		margin-top: 30px;
	}

	/* Footer */
	.footer {
		margin-top: 40px;
		text-align: center;
	}

	/* General text styles for the page */
	p {
		font-size: 1.2em;
	}
</style>
<body>

<%
String custId = request.getParameter("customerId");
String address = request.getParameter("address");
String city = request.getParameter("city");
String state = request.getParameter("state");
String postalCode = request.getParameter("postalCode");
String country = request.getParameter("country");
String paymentType = request.getParameter("paymentType");
String paymentNumber = request.getParameter("paymentNumber");
String paymentExpiryDate = request.getParameter("paymentExpiryDate");

@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

boolean addressValid = true;
String regex = "^[0-9]{2,4} [A-Za-z][A-Za-z ]*$"; // Regex: 2-4 digits, followed by a space, then at least one letter
if(address == null && !address.matches(regex)) addressValid = false;
regex = "^[A-Za-z ]+$";// Non-empty, letters and spaces only
if(city == null && !city.matches(regex)) addressValid = false; 
regex = "^[A-Z]{2}$"; // Exactly two uppercase letters
if(state == null && !state.matches(regex)) addressValid = false;
regex = "^(\\d{5}(-\\d{4})?|[A-Za-z]\\d[A-Za-z] \\d[A-Za-z]\\d)$";// US format: 5 digits or 5-4 digits, Canadian format: A1A 1A1
if(postalCode == null && !postalCode.matches(regex)) addressValid = false;
regex = "^[A-Za-z ]+$";// Non-empty, letters and spaces only
if(country == null && !country.matches(regex)) addressValid = false;
if(!addressValid){
	out.println("<h4>ERROR: Invalid address.</h4>");
	return;
}

boolean paymentValid = true;
regex = "^[A-Za-z ]+$";// Non-empty, letters and spaces only
if(paymentType == null && !paymentType.matches(regex)) paymentValid = false;
regex = "^\\d{4,30}$";// Non-empty, letters and spaces only
if(paymentNumber == null && !paymentNumber.matches(regex)) paymentValid = false;
if (paymentExpiryDate == null || paymentExpiryDate.isEmpty()) paymentValid = false;// Ensure the date is in the format "yyyy-MM-dd" and is not in the past
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
sdf.setLenient(false); // Disable lenient parsing to ensure strict date format validation
try {
    Date expiryDate = sdf.parse(paymentExpiryDate);
    Date today = new Date();
    // Ensure the expiry date is not in the past
    if(expiryDate.before(today)) paymentValid = false;
} catch (ParseException e) {
    paymentValid = false; // Invalid date format
}
if(!paymentValid){
	out.println("<h4>ERROR: Invalid payment method.</h4>");
	return;
}

try {
Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
} catch (java.lang.ClassNotFoundException e) {
out.println("ClassNotFoundException: " + e);
}

try (Connection con = DriverManager.getConnection(url, uid, pw)) {
con.setAutoCommit(false);// Start transaction

Statement stmt = con.createStatement(); 
stmt.execute("USE orders");

String customerQuery = "SELECT COUNT(customerId) FROM customer WHERE customerId = ?";
try (PreparedStatement pstmt = con.prepareStatement(customerQuery)) {
pstmt.setString(1, custId);
ResultSet rs = pstmt.executeQuery();
if (rs.next() && rs.getInt(1) == 0) {
out.println("<h4>ERROR: Customer does not exist. </h4>");
return;// Exit the process
}
}

if (productList == null || productList.isEmpty()) {
out.println("<h4>Shopping cart is empty</h4>");
return;// Exit the process
}

String sql = "INSERT INTO ordersummary (customerId, orderDate, totalAmount, shiptoAddress, shiptoCity, shiptoState, shiptoPostalCode, shiptoCountry) VALUES (?, GETDATE(), 0, ?, ?, ?, ?, ?)";
int orderId;
try (PreparedStatement pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
pstmt.setString(1, custId);
pstmt.setString(2, address);
pstmt.setString(3, city);
pstmt.setString(4, state);
pstmt.setString(5, postalCode);
pstmt.setString(6, country);
pstmt.executeUpdate();
ResultSet keys = pstmt.getGeneratedKeys();
keys.next();
orderId = keys.getInt(1);
}

double totalAmount = 0;

String insertProduct = "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
try (PreparedStatement pstmt = con.prepareStatement(insertProduct)) {
for (Map.Entry<String, ArrayList<Object>> entry : productList.entrySet()) {
ArrayList<Object> product = entry.getValue();
String productId = (String) product.get(0);
String price = (String) product.get(2);
double pr = Double.parseDouble(price);
int qty = ((Integer) product.get(3)).intValue();

pstmt.setInt(1, orderId);
pstmt.setString(2, productId);
pstmt.setInt(3, qty);
pstmt.setDouble(4, pr);
pstmt.executeUpdate();

totalAmount += pr * qty;
}
}

String updateTotal = "UPDATE ordersummary SET totalAmount = ? WHERE orderId = ?";
try (PreparedStatement pstmt = con.prepareStatement(updateTotal)) {
pstmt.setDouble(1, totalAmount);
pstmt.setInt(2, orderId);
pstmt.executeUpdate();
}
String showOrder = "SELECT productId, quantity, price FROM orderproduct WHERE orderId = ?";
try (PreparedStatement pstmt = con.prepareStatement(showOrder)) {
pstmt.setInt(1, orderId);
ResultSet resultSet = pstmt.executeQuery();

out.println("<h1>Order Summary</h1>");
out.println("<table class='product-details'>");
out.println("<tr>");
out.println("<th>Product Id</th>");
out.println("<th>Quantity</th>");
out.println("<th>Price</th>");
out.println("<th>Order Total</th>");
out.println("</tr>");

NumberFormat currFormat = NumberFormat.getCurrencyInstance();
double cumulativeTotal = 0.0;

while (resultSet.next()) {
int productId = resultSet.getInt("productId");
int quantity = resultSet.getInt("quantity");
double price = resultSet.getDouble("price");
double total = quantity * price;
cumulativeTotal += total;

out.println("<tr>");
out.println("<td>" + productId + "</td>");
out.println("<td>" + quantity + "</td>");
out.println("<td>" + currFormat.format(price) + "</td>");
out.println("<td>" + currFormat.format(total) + "</td>");
out.println("</tr>");
}
out.println("<tr>");
out.println("<td colspan='3' style='text-align:right; font-weight:bold;'>Grand Total</td>");
out.println("<td>" + currFormat.format(cumulativeTotal) + "</td>");
out.println("</tr>");
out.println("</table>");
}

String customernameQuery = "SELECT firstName, lastName FROM customer WHERE customerId = ?";
String recipientFirstName = "";
String recipientLastName = "";
try (PreparedStatement pstmt = con.prepareStatement(customernameQuery)) {
pstmt.setString(1, custId);
ResultSet rs = pstmt.executeQuery();
if (rs.next()) {
recipientFirstName = rs.getString("firstName");
recipientLastName = rs.getString("lastName");
} else {
out.println("<h4>ERROR: Customer does not exist.</h4>");
return; 
}
}

session.removeAttribute("productList");
out.println("<h1>Order Processed Successfully</h1>");
out.println("<p>Your reference number is: <strong>" + orderId + "</strong></p>");
out.println("<p>Thank you very much, " + recipientFirstName + " " + recipientLastName + "</p>");

out.println("<br><h2>Shipping to:</h2>");
out.println("<p>"+address+", "+city+", "+state+" "+postalCode+", "+country+"</p>");
out.println("<br><h2>Payed using:</h2>");
out.println("<p>Payment Type: "+paymentType+"</p>");
out.println("<p>Payment Number: "+paymentNumber+"</p>");
out.println("<p>Payment Expiry Date: "+paymentExpiryDate+"</p>");

out.println("<form action='index.jsp'>");
	out.println("<button type='submit'>Go Back to Shop</button>");
	out.println("</form>");
con.commit();	
}
catch (SQLException e) {
out.println(e);
}
%>
</body>
</html>


