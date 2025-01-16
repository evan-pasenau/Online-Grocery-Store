<%@ page language="java" import="java.io.*,java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%
    session = request.getSession(true);
    String authenticatedUser = (String) session.getAttribute("authenticatedUser");
    if (authenticatedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String resultMessage = null;
    try {
        resultMessage = updateCustomerInfo(out, request, session, authenticatedUser);
    } catch (IOException e) {
        System.err.println(e);
    }

    if (resultMessage == null) {
        // Successfully updated
        response.sendRedirect("index.jsp");
    } else {
        // Failed to update, store message and redirect back to edit page
        session.setAttribute("editMessage", resultMessage);
        response.sendRedirect("editCustomer.jsp");
    }
%>

<%!
    String updateCustomerInfo(JspWriter out, HttpServletRequest request, HttpSession session, String username) throws IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNum = request.getParameter("phoneNum");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String postalCode = request.getParameter("postalCode");
        String country = request.getParameter("country");

        // Validate inputs
        if (firstName == null || lastName == null || email == null || phoneNum == null || 
            address == null || city == null || state == null || postalCode == null || country == null ||
            firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty() || 
            phoneNum.trim().isEmpty() || address.trim().isEmpty() || city.trim().isEmpty() || 
            state.trim().isEmpty() || postalCode.trim().isEmpty() || country.trim().isEmpty()) {
            return "All fields are required.";
        }

        int rowUpd = 0;
        try {
            getConnection();
            Statement stmt = con.createStatement(); 
            stmt.execute("USE orders");
            stmt.close();

            String sql = "UPDATE customer SET firstName=?, lastName=?, email=?, phoneNum=?, address=?, city=?, state=?, postalCode=?, country=? WHERE userid=?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, email);
            pstmt.setString(4, phoneNum);
            pstmt.setString(5, address);
            pstmt.setString(6, city);
            pstmt.setString(7, state);
            pstmt.setString(8, postalCode);
            pstmt.setString(9, country);
            pstmt.setString(10, username);

            rowUpd = pstmt.executeUpdate();
            pstmt.close();
        } catch (SQLException ex) {
            out.println(ex);
            return "Database error occurred while updating.";
        } finally {
            closeConnection();
        }

        if (rowUpd > 0) {
            // Successfully updated
            return null;
        } else {
            return "No changes were made or user not found.";
        }
    }
%>
