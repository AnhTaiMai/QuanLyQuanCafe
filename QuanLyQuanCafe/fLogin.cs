using QuanLyQuanCafe.DAO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QuanLyQuanCafe
{
    public partial class fLogin : Form
    {
        public fLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            string userName = txbUserName.Text;
            string passWord = txbPassWord.Text;
            if (Login(userName, passWord))
            {
                fTableManager f = new fTableManager();
                this.Hide();        // an form dang nhap
                f.ShowDialog();     // sau khi an fDangNhap thi hien len form fTM (luu y: neu k co dialog thi se hien thi ca 2 form)
                this.Show();        // this.show hien thi fDangNhap khi tat fTM
            }
            else
            {
                MessageBox.Show("sai tên tài khoản hoặc mật khẩu!");
            }
        }

        bool Login(string userName, string passWord)
        {
            return AccountDAO.Instance.Login(userName, passWord);          
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void fLogin_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (MessageBox.Show("Bạn có thực sự muốn thoát?","Thông báo", MessageBoxButtons.OKCancel) != DialogResult.OK)
            { 
                e.Cancel = true;    
            }
        }

        private void fLogin_Load(object sender, EventArgs e)
        {

        }
    }
}