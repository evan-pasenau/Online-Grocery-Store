<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart</title>
</head>
<body>

<%
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null) {
    out.println("<h1>Your shopping cart is empty!</h1>");
    productList = new HashMap<String, ArrayList<Object>>();
} else {
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();

    out.println("<h1>Your Shopping Cart</h1>");
    out.print("<table border='1' cellpadding='5' cellspacing='0'><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
    out.println("<th>Price</th><th>Subtotal</th></tr>");

    double total = 0;
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
    while (iterator.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
        ArrayList<Object> product = entry.getValue();
        if (product.size() < 4) {
            out.println("Expected product with four entries. Got: " + product);
            continue;
        }

        // Extracting values
        String productId = (String) product.get(0);
        String productName = (String) product.get(1);
        Object price = product.get(2);
        Object itemqty = product.get(3);

        double pr = 0;
        int qty = 0;

        try {
            pr = Double.parseDouble(price.toString());
        } catch (Exception e) {
            out.println("Invalid price for product: " + productId + " price: " + price);
        }
        try {
            qty = Integer.parseInt(itemqty.toString());
        } catch (Exception e) {
            out.println("Invalid quantity for product: " + productId + " quantity: " + itemqty);
        }

        out.print("<tr>");
        out.print("<td>" + productId + "</td>");
        out.print("<td>" + productName + "</td>");
        out.print("<td align=\"center\">");
        out.print("<form method=\"post\" action=\"qtyupdate.jsp\" class=\"w-25\">");
        out.print("<input name=\"qty\" class=\"form-control\" min=\"1\" type=\"number\" value=\"" + qty + "\">");
        out.print("<input type=\"hidden\" name=\"pid\" value=\"" + entry.getKey() + "\">");
        out.print("</form>");
        out.print("</td>");
        out.print("<td align=\"right\">" + currFormat.format(pr) + "</td>");
        out.print("<td align=\"right\">" + currFormat.format(pr * qty) + "</td>");
       
		out.print("<td>");
        out.print("<form method=\"post\" action=\"removeItem.jsp\" style=\"display:inline;\">");
        out.print("<input type=\"hidden\" name=\"key\" value=\"" + entry.getKey() + "\">");
        out.print("<input type=\"submit\" value=\"Remove\">");
        out.print("</form>");
        out.print("</td>");

        out.println("</tr>");

        total += pr * qty;
    }

    out.println("<tr><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
            + "<td align=\"right\">" + currFormat.format(total) + "</td></tr>");
    out.println("</table>");
    out.println("<h2><a href=\"checkout.jsp\">Check Out</a></h2>");
}
%>
<h2><a href="listprod.jsp">Continue Shopping</a></h2>
</body>
</html>
