// Copyright (c) 2017 The PIVX developers
// Copyright (c) 2018 The MERGE developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "zpivcontroldialog.h"
#include "ui_zpivcontroldialog.h"

#include "main.h"
#include "walletmodel.h"

using namespace std;

std::list<std::string> ZPivControlDialog::listSelectedMints;
std::list<CZerocoinMint> ZPivControlDialog::listMints;

ZPivControlDialog::ZPivControlDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ZPivControlDialog),
    model(0)
{
    ui->setupUi(this);
    listMints.clear();
    privacyDialog = (PrivacyDialog*)parent;

    // click on checkbox
    connect(ui->treeWidget, SIGNAL(itemChanged(QTreeWidgetItem*, int)), this, SLOT(updateSelection(QTreeWidgetItem*, int)));

    // push select/deselect all button
    connect(ui->pushButtonAll, SIGNAL(clicked()), this, SLOT(ButtonAllClicked()));
}

ZPivControlDialog::~ZPivControlDialog()
{
    delete ui;
}

void ZPivControlDialog::setModel(WalletModel *model)
{
    this->model = model;
    updateList();
}

//Update the tree widget
void ZPivControlDialog::updateList()
{
    // need to prevent the slot from being called each time something is changed
    ui->treeWidget->blockSignals(true);
    ui->treeWidget->clear();

    // add a top level item for each denomination
    QFlags<Qt::ItemFlag> flgTristate = Qt::ItemIsEnabled | Qt::ItemIsUserCheckable | Qt::ItemIsTristate;
    map<libzerocoin::CoinDenomination, int> mapDenomPosition;
    for (auto denom : libzerocoin::zerocoinDenomList) {
        QTreeWidgetItem* itemDenom(new QTreeWidgetItem);
        ui->treeWidget->addTopLevelItem(itemDenom);

        //keep track of where this is positioned in tree widget
        mapDenomPosition[denom] = ui->treeWidget->indexOfTopLevelItem(itemDenom);

        itemDenom->setFlags(flgTristate);
        itemDenom->setText(COLUMN_DENOMINATION, QString::number(denom));
    }

    ui->treeWidget->blockSignals(false);
    updateLabels();
}

// Update the list when a checkbox is clicked
void ZPivControlDialog::updateSelection(QTreeWidgetItem* item, int column)
{
}

// Update the Quantity and Amount display
void ZPivControlDialog::updateLabels()
{
    int64_t nAmount = 0;
    for (const CZerocoinMint mint : listMints) {
        if (count(listSelectedMints.begin(), listSelectedMints.end(), mint.GetValue().GetHex())) {
            nAmount += mint.GetDenomination();
        }
    }

    //update this dialog's labels
    ui->labelZPiv_int->setText(QString::number(nAmount));
    ui->labelQuantity_int->setText(QString::number(listSelectedMints.size()));

    //update PrivacyDialog labels
    privacyDialog->setZPivControlLabels(nAmount, listSelectedMints.size());
}

std::vector<CZerocoinMint> ZPivControlDialog::GetSelectedMints()
{
    std::vector<CZerocoinMint> listReturn;
    for (const CZerocoinMint mint : listMints) {
        if (count(listSelectedMints.begin(), listSelectedMints.end(), mint.GetValue().GetHex())) {
            listReturn.emplace_back(mint);
        }
    }

    return listReturn;
}

// select or deselect all of the mints
void ZPivControlDialog::ButtonAllClicked()
{
    ui->treeWidget->blockSignals(true);
    Qt::CheckState state = Qt::Checked;
    for(int i = 0; i < ui->treeWidget->topLevelItemCount(); i++) {
        if(ui->treeWidget->topLevelItem(i)->checkState(COLUMN_CHECKBOX) != Qt::Unchecked) {
            state = Qt::Unchecked;
            break;
        }
    }

    //much quicker to start from scratch than to have QT go through all the objects and update
    ui->treeWidget->clear();

    if(state == Qt::Checked) {
        for(const CZerocoinMint mint : listMints)
            listSelectedMints.emplace_back(mint.GetValue().GetHex());
    } else {
        listSelectedMints.clear();
    }

    updateList();
}

