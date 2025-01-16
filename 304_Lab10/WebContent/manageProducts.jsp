<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Products</title>
</head>
<body>
<%
    getConnection();

    String action = request.getParameter("action");
    if (action != null) {
        if ("update".equals(action)) {
            String productId = request.getParameter("productId");
            String productName = request.getParameter("productName");
            String price = request.getParameter("productPrice");
            String productImageURL = request.getParameter("productImageURL");
            String productDesc = request.getParameter("productDesc");
            String categoryId = request.getParameter("categoryId");

            if (productId != null && productName != null && price != null && productImageURL != null && productDesc != null && categoryId != null) {
                try {
                    Statement stmt = con.createStatement(); 
                    stmt.execute("USE orders");
                    stmt.close();

                    PreparedStatement ps = con.prepareStatement(
                        "UPDATE product SET productName=?, productPrice=?, productImageURL=?, productDesc=?, categoryId=? WHERE productId=?");
                    ps.setString(1, productName);
                    ps.setBigDecimal(2, new java.math.BigDecimal(price));
                    ps.setString(3, productImageURL);
                    ps.setString(4, productDesc);
                    ps.setInt(5, Integer.parseInt(categoryId));
                    ps.setInt(6, Integer.parseInt(productId));
                    ps.executeUpdate();
                    ps.close();
                } catch (SQLException e) {
                    out.println("Error updating product: " + e.getMessage());
                } catch (NumberFormatException e) {
                    out.println("Invalid number format: " + e.getMessage());
                }
            }

        } else if ("delete".equals(action)) {
            String productId = request.getParameter("productId");
            if (productId != null) {
                try {
                    int pId = Integer.parseInt(productId);
                    Statement stmt = con.createStatement(); 
                    stmt.execute("USE orders");
                    stmt.close();

                    PreparedStatement psInv = con.prepareStatement("DELETE FROM productinventory WHERE productId=?");
                    psInv.setInt(1, pId);
                    psInv.executeUpdate();
                    psInv.close();
                    
                    PreparedStatement psOrdProd = con.prepareStatement("DELETE FROM orderproduct WHERE productId=?");
                    psOrdProd.setInt(1, pId);
                    psOrdProd.executeUpdate();
                    psOrdProd.close();

                    PreparedStatement ps = con.prepareStatement("DELETE FROM product WHERE productId=?");
                    ps.setInt(1, pId);
                    ps.executeUpdate();
                    ps.close();
                } catch (SQLException e) {
                    out.println("Error deleting product: " + e.getMessage());
                } catch (NumberFormatException e) {
                    out.println("Invalid product ID: " + e.getMessage());
                }
            }

        } else if ("add".equals(action)) {
            String productName = request.getParameter("productName");
            String price = request.getParameter("productPrice");
            String productImageURL = request.getParameter("productImageURL");
            String productDesc = request.getParameter("productDesc");
            String categoryId = request.getParameter("categoryId");

            if (productName != null && price != null && productImageURL != null && productDesc != null && categoryId != null) {
                try {
                    Statement stmt = con.createStatement(); 
                    stmt.execute("USE orders");
                    stmt.close();

                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO product (productName, productPrice, productImageURL, productDesc, categoryId) VALUES (?,?,?,?,?)");
                    ps.setString(1, productName);
                    ps.setBigDecimal(2, new java.math.BigDecimal(price));
                    ps.setString(3, productImageURL);
                    ps.setString(4, productDesc);
                    ps.setInt(5, Integer.parseInt(categoryId));
                    ps.executeUpdate();
                    ps.close();
                } catch (SQLException e) {
                    out.println("Error adding product: " + e.getMessage());
                } catch (NumberFormatException e) {
                    out.println("Invalid number format: " + e.getMessage());
                }
            }
        }
    }

    try {
        Statement stmt = con.createStatement(); 
        stmt.execute("USE orders");
        ResultSet rs = stmt.executeQuery("SELECT productId, productName, productPrice, productImageURL, productDesc, categoryId FROM product ORDER BY productId");

        out.println("<h1>Manage Products</h1>");
        out.println("<table border='1' cellpadding='5' cellspacing='0'>");
        out.println("<tr><th>ID</th><th>Name</th><th>Price</th><th>Image URL</th><th>Description</th><th>Category ID</th><th>Actions</th></tr>");

        while (rs.next()) {
            int pid = rs.getInt("productId");
            String pname = rs.getString("productName");
            String pprice = rs.getBigDecimal("productPrice").toString();
            String pImageURL = rs.getString("productImageURL");
            String pDesc = rs.getString("productDesc");
            int catId = rs.getInt("categoryId");

            out.println("<tr>");
            out.println("<form method='post'>");
            out.println("<td><input type='text' name='productId' value='" + pid + "' readonly></td>");
            out.println("<td><input type='text' name='productName' value='" + pname + "'></td>");
            out.println("<td><input type='text' name='productPrice' value='" + pprice + "'></td>");
            out.println("<td><input type='text' name='productImageURL' value='" + pImageURL + "'></td>");
            out.println("<td><input type='text' name='productDesc' value='" + pDesc + "'></td>");
            out.println("<td><input type='text' name='categoryId' value='" + catId + "'></td>");
            out.println("<td>");
            out.println("<input type='submit' name='action' value='update'>");
            out.println("<input type='submit' name='action' value='delete'>");
            out.println("</td>");
            out.println("</form>");
            out.println("</tr>");
        }
        rs.close();
        stmt.close();

        out.println("</table>");

    } catch (SQLException e) {
        out.println("Error fetching products: " + e.getMessage());
    }
%>

<h2>Add New Product</h2>
<form method="post">
<table>
    <tr>
        <td>Name:</td>
        <td><input type="text" name="productName" required></td>
    </tr>
    <tr>
        <td>Price:</td>
        <td><input type="text" name="productPrice" required></td>
    </tr>
    <tr>
        <td>Image URL:</td>
        <td><input type="text" name="productImageURL" required></td>
    </tr>
    <tr>
        <td>Description:</td>
        <td><input type="text" name="productDesc" required></td>
    </tr>
    <tr>
        <td>Category ID:</td>
        <td><input type="text" name="categoryId" required></td>
    </tr>
    <tr>
        <td colspan="2"><input type="submit" name="action" value="add"></td>
    </tr>
</table>
</form>

</body>
</html>
