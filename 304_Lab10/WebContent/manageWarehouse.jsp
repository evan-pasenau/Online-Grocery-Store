<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Warehouse</title>
</head>
<body>
<%
    getConnection();

    String action = request.getParameter("action");
    if (action != null) {
        if ("update".equals(action)) {
            String warehouseId = request.getParameter("warehouseId");
            String warehouseName = request.getParameter("warehouseName");

            if (warehouseId != null && warehouseName != null) {
                try {
                    Statement stmt = con.createStatement(); 
                    stmt.execute("USE orders");
                    stmt.close();
                    PreparedStatement ps = con.prepareStatement(
                        "UPDATE warehouse SET warehouseName=? WHERE warehouseId=?");
                    ps.setString(1, warehouseName);
                    ps.setInt(2, Integer.parseInt(warehouseId));
                    ps.executeUpdate();
                    ps.close();
                } catch (SQLException e) {
                    out.println("Error updating warehouse: " + e.getMessage());
                } catch (NumberFormatException e) {
                    out.println("Invalid number format: " + e.getMessage());
                }
            }

        } else if ("add".equals(action)) {
            String warehouseName = request.getParameter("warehouseName");

            if (warehouseName != null) {
                try {
                    Statement stmt = con.createStatement(); 
                    stmt.execute("USE orders");
                    stmt.close();

                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO warehouse (warehouseName) VALUES (?)");
                    ps.setString(1, warehouseName);
                    ps.executeUpdate();
                    ps.close();
                } catch (SQLException e) {
                    out.println("Error adding warehouse: " + e.getMessage());
                }
            }
        }
    }

    try {
        Statement stmt = con.createStatement(); 
        stmt.execute("USE orders");
        ResultSet rs = stmt.executeQuery("SELECT warehouseId, warehouseName FROM warehouse ORDER BY warehouseId");

        out.println("<h1>Manage Warehouses</h1>");
        out.println("<table border='1' cellpadding='5' cellspacing='0'>");
        out.println("<tr><th>ID</th><th>Name</th><th>Actions</th></tr>");

        while (rs.next()) {
            int wid = rs.getInt("warehouseId");
            String wname = rs.getString("warehouseName");

            out.println("<tr>");
            out.println("<form method='post'>");
            out.println("<td><input type='text' name='warehouseId' value='" + wid + "' readonly></td>");
            out.println("<td><input type='text' name='warehouseName' value='" + wname + "'></td>");
            out.println("<td>");
            out.println("<input type='submit' name='action' value='update'>");
            // If you want a delete function, you can add it here similar to products
            out.println("</td>");
            out.println("</form>");
            out.println("</tr>");
        }
        rs.close();
        stmt.close();

        out.println("</table>");

    } catch (SQLException e) {
        out.println("Error fetching warehouses: " + e.getMessage());
    }
%>

<h2>Add New Warehouse</h2>
<form method="post">
<table>
    <tr>
        <td>Name:</td>
        <td><input type="text" name="warehouseName" required></td>
    </tr>
    <tr>
        <td colspan="2"><input type="submit" name="action" value="add"></td>
    </tr>
</table>
</form>

</body>
</html>
