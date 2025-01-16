<%@ page import="java.io.IOException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    try {//trys to update incase of invalid data entry
        updateProduct(request, session);
        response.sendRedirect("showcart.jsp");//sends back to updated showcart page
    } catch (IOException e) {
        System.err.println(e);
    }
%>
<%!
    public void updateProduct(HttpServletRequest request, HttpSession session) throws IOException {
        //gets productId and new qty
        String quantity = request.getParameter("qty");
        String pid = request.getParameter("pid");

        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
        if (productList != null && productList.containsKey(pid)) {
            //commits new quantity to the productList for the cart
            productList.get(pid).set(3, Integer.parseInt(quantity));
            session.setAttribute("productList", productList);
        }
    }
%>
