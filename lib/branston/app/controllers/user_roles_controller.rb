#    This file is part of Branston.
#
#    Branston is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation.
#
#    Branston is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Branston.  If not, see <http://www.gnu.org/licenses/>.

class UserRolesController < ApplicationController

  layout 'main'

  before_filter :login_required

  # GET /user_roles
  # GET /user_roles.xml
  def index
    @user_roles = UserRole.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_roles }
    end
  end

  # GET /user_roles/1
  # GET /user_roles/1.xml
  def show
    @user_role = UserRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_role }
    end
  end

  # GET /user_roles/new
  # GET /user_roles/new.xml
  def new
    @user_role = UserRole.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_role }
    end
  end

  # GET /user_roles/1/edit
  def edit
    @user_role = UserRole.find(params[:id])
  end

  # POST /user_roles
  # POST /user_roles.xml
  def create
    @user_role = UserRole.new(params[:user_role])

    respond_to do |format|
      if @user_role.save
        flash[:notice] = 'UserRole was successfully created.'
        format.html { redirect_to(@user_role) }
        format.xml  { render :xml => @user_role, :status => :created, :location => @user_role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_roles/1
  # PUT /user_roles/1.xml
  def update
    @user_role = UserRole.find(params[:id])

    respond_to do |format|
      if @user_role.update_attributes(params[:user_role])
        flash[:notice] = 'UserRole was successfully updated.'
        format.html { redirect_to(@user_role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_roles/1
  # DELETE /user_roles/1.xml
  def destroy
    @user_role = UserRole.find(params[:id])
    @user_role.destroy

    respond_to do |format|
      format.html { redirect_to(user_roles_url) }
      format.xml  { head :ok }
    end
  end
end

