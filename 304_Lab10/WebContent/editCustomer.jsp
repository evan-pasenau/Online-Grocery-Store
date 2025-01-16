<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%
    session = request.getSession(true);
    String authenticatedUser = (String) session.getAttribute("authenticatedUser");
    if (authenticatedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = (String) session.getAttribute("editMessage");
    if (message != null) {
        out.println("<p style='color:red;'>" + message + "</p>");
        session.removeAttribute("editMessage");
    }

    String firstName = "";
    String lastName = "";
    String email = "";
    String phoneNum = "";
    String address = "";
    String city = "";
    String state = "";
    String postalCode = "";
    String country = "";

    try {
        getConnection();
        Statement stmt = con.createStatement();
        stmt.execute("USE orders");
        PreparedStatement pstmt = con.prepareStatement(
          "SELECT firstName, lastName, email, phoneNum, address, city, state, postalCode, country FROM customer WHERE userid = ?");
        pstmt.setString(1, authenticatedUser);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            firstName = rs.getString("firstName");
            lastName = rs.getString("lastName");
            email = rs.getString("email");
            phoneNum = rs.getString("phoneNum");
            address = rs.getString("address");
            city = rs.getString("city");
            state = rs.getString("state");
            postalCode = rs.getString("postalCode");
            country = rs.getString("country");
        }
        rs.close();
        pstmt.close();
    } catch (SQLException ex) {
        out.println("Database error: " + ex.getMessage());
    } finally {
        closeConnection();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Customer Information</title>
</head>
<body>
<h1>Edit Your Information</h1>
<form method="post" action="validateEditCustomer.jsp">
    <table>
        <tr>
            <td>First Name:</td>
            <td><input type="text" name="firstName" value="<%= firstName %>" required></td>
        </tr>
        <tr>
            <td>Last Name:</td>
            <td><input type="text" name="lastName" value="<%= lastName %>" required></td>
        </tr>
        <tr>
            <td>Email:</td>
            <td><input type="email" name="email" value="<%= email %>" required></td>
        </tr>
        <tr>
            <td>Phone Number:</td>
            <td><input type="text" name="phoneNum" value="<%= phoneNum %>" required></td>
        </tr>
        <tr>
            <td>Address:</td>
            <td><input type="text" name="address" value="<%= address %>" required></td>
        </tr>
        <tr>
            <td>City:</td>
            <td><input type="text" name="city" value="<%= city %>" required></td>
        </tr>
        <tr>
            <td>State:</td>
            <td><input type="text" name="state" value="<%= state %>" required></td>
        </tr>
        <tr>
            <td>Postal Code:</td>
            <td><input type="text" name="postalCode" value="<%= postalCode %>" required></td>
        </tr>
        <tr>
            <td>Country:</td>
            <td><input type="text" name="country" value="<%= country %>" required></td>
        </tr>
    </table>
    <br>
    <input type="submit" value="Update Info">
</form>

</body>
</html>
