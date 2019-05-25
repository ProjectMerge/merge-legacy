// Copyright (c) 2018 -2019 MERGE Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "checkpoints.h"
#include "main.h"
#include "rpc/server.h"
#include "sync.h"
#include "util.h"

#include <stdint.h>

#include "json/json_spirit_value.h"
#include "utilmoneystr.h"
#include "base58.h"

using namespace json_spirit;
using namespace std;

extern void TxToJSON(const CTransaction& tx, const uint256 hashBlock, Object& entry);

// Data For Explorer to minimize RPC requests 
Object explorerDataToJSON(const CBlock& block, const CBlockIndex* blockindex, bool txDetails = true)
{
    Object result;
    result.push_back(Pair("hash", block.GetHash().GetHex()));
    int confirmations = -1;
    // Only report confirmations if the block is on the main chain
    if (chainActive.Contains(blockindex))
        confirmations = chainActive.Height() - blockindex->nHeight + 1;
    result.push_back(Pair("confirmations", confirmations));
    result.push_back(Pair("size", (int)::GetSerializeSize(block, SER_NETWORK, PROTOCOL_VERSION)));
    result.push_back(Pair("height", blockindex->nHeight));
    result.push_back(Pair("version", block.nVersion));
    result.push_back(Pair("merkleroot", block.hashMerkleRoot.GetHex()));
    Array txs;
    BOOST_FOREACH (const CTransaction& tx, block.vtx) {
        if (txDetails) {
            Object objTx;
            TxToJSON(tx, uint256(0), objTx);
            txs.push_back(objTx);
        } else
            txs.push_back(tx.GetHash().GetHex());
    }
    result.push_back(Pair("tx", txs));
    result.push_back(Pair("time", block.GetBlockTime()));
    result.push_back(Pair("nonce", (uint64_t)block.nNonce));
    result.push_back(Pair("bits", strprintf("%08x", block.nBits)));
    result.push_back(Pair("difficulty", GetDifficulty(blockindex)));
    result.push_back(Pair("chainwork", blockindex->nChainWork.GetHex()));

    if (blockindex->pprev)
        result.push_back(Pair("previousblockhash", blockindex->pprev->GetBlockHash().GetHex()));
    CBlockIndex* pnext = chainActive.Next(blockindex);
    if (pnext)
        result.push_back(Pair("nextblockhash", pnext->GetBlockHash().GetHex()));

    result.push_back(Pair("moneysupply",ValueFromAmount(blockindex->nMoneySupply)));

    return result;
}

Value crawlexplorerdata(const Array& params, bool fHelp)
{
    if (fHelp || params.size() < 1 || params.size() > 2)
        throw runtime_error(
            "crawlexplorerdata \"height\" ( verbose )\n"
            "\nIf verbose is false, returns a string that is serialized, hex-encoded data for block 'hash'.\n"
            "If verbose is true, returns an Object with information about block <hash>.\n"
            "\nArguments:\n"
            "1. \"height\"          (numeric, required) The block index\n"
            "2. verbose           (boolean, optional, default=true) true for a json object, false for the hex encoded data\n"
            "\nResult (for verbose = true):\n"
            "{\n"
            "  \"hash\" : \"hash\",     (string) the block hash (same as provided)\n"
            "  \"confirmations\" : n,   (numeric) The number of confirmations, or -1 if the block is not on the main chain\n"
            "  \"size\" : n,            (numeric) The block size\n"
            "  \"height\" : n,          (numeric) The block height or index\n"
            "  \"version\" : n,         (numeric) The block version\n"
            "  \"merkleroot\" : \"xxxx\", (string) The merkle root\n"
            "  \"tx\" : [               (array of json objects) The transaction Objects\n"
            "             {\n"
            "               \"hex\" : \"data\",       (string) The serialized, hex-encoded data for 'txid'\n"
            "               \"txid\" : \"id\",        (string) The transaction id (same as provided)\n"
            "               \"version\" : n,          (numeric) The version\n"
            "               \"locktime\" : ttt,       (numeric) The lock time\n"
            "               \"vin\" : [               (array of json objects)\n"
            "                  {\n"
            "                    \"txid\": \"id\",    (string) The transaction id\n"
            "                    \"vout\": n,         (numeric) \n"
            "                    \"scriptSig\": {     (json object) The script\n"
            "                      \"asm\": \"asm\",  (string) asm\n"
            "                      \"hex\": \"hex\"   (string) hex\n"
            "                    },\n"
            "                    \"sequence\": n      (numeric) The script sequence number\n"
            "                  }\n"
            "                  ,...\n"
            "               ],\n"
            "               \"vout\" : [              (array of json objects)\n"
            "                  {\n"
            "                    \"value\" : x.xxx,            (numeric) The value in btc\n"
            "                    \"n\" : n,                    (numeric) index\n"
            "                    \"scriptPubKey\" : {          (json object)\n"
            "                      \"asm\" : \"asm\",          (string) the asm\n"
            "                      \"hex\" : \"hex\",          (string) the hex\n"
            "                      \"reqSigs\" : n,            (numeric) The required sigs\n"
            "                      \"type\" : \"pubkeyhash\",  (string) The type, eg 'pubkeyhash'\n"
            "                      \"addresses\" : [           (json array of string)\n"
            "                        \"MERGEaddress\"        (string) MERGE address\n"
            "                        ,...\n"
            "                      ]\n"
            "                    }\n"
            "                }\n"
            "                ,...\n"
            "       ],\n"
            "   }\n"
            "  ],\n"
            "  \"time\" : ttt,          (numeric) The block time in seconds since epoch (Jan 1 1970 GMT)\n"
            "  \"nonce\" : n,           (numeric) The nonce\n"
            "  \"bits\" : \"1d00ffff\", (string) The bits\n"
            "  \"difficulty\" : x.xxx,  (numeric) The difficulty\n"
            "  \"previousblockhash\" : \"hash\",  (string) The hash of the previous block\n"
            "  \"nextblockhash\" : \"hash\"       (string) The hash of the next block\n"
            "  \"moneysupply\" : \"supply\"       (numeric) The money supply when this block was added to the blockchain\n"
            "}\n"
            "\nResult (for verbose=false):\n"
            "\"data\"             (string) A string that is serialized, hex-encoded data for block 'hash'.\n"
            "\nExamples:\n" +
            HelpExampleCli("crawlexplorerdata", "\"50\"") + HelpExampleRpc("crawlexplorerdata", "\"50\" \"true\" "));

    int nHeight = params[0].get_int();
    if (nHeight < 0 || nHeight > chainActive.Height())
        throw JSONRPCError(RPC_INVALID_PARAMETER, "Block height out of range");

    CBlock block;
    CBlockIndex* pblockindex = chainActive[nHeight];

    bool fVerbose = true;
    if (params.size() > 1)
        fVerbose = params[1].get_bool();

    if (!ReadBlockFromDisk(block, pblockindex))
        throw JSONRPCError(RPC_INTERNAL_ERROR, "Can't read block from disk");

    if (!fVerbose) {
        CDataStream ssBlock(SER_NETWORK, PROTOCOL_VERSION);
        ssBlock << block;
        std::string strHex = HexStr(ssBlock.begin(), ssBlock.end());
        return strHex;
    }

    return explorerDataToJSON(block, pblockindex);
}