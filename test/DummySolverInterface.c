#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

double *fake_read_write_buffer;
const int SIZE = 6;
int fake_dimensions;
const char *fake_mesh_name;
int *fake_ids;
int n_fake_vertices;
const char *fake_data_name;
double *fake_bounding_box;
double *fake_coordinates;

void precicec_createSolverInterface(const char *participantName,
                                    const char *configurationFileName,
                                    int solverProcessIndex,
                                    int solverProcessSize)
{
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_dimensions = 3;
    fake_mesh_name = "MeshOne";
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}

void precicec_createSolverInterface_withCommunicator(const char *participantName,
                                                     const char *configurationFileName,
                                                     int solverProcessIndex,
                                                     int solverProcessSize,
                                                     void *communicator)
{
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_dimensions = 3;
    fake_mesh_name = "MeshOne";
    fake_data_name = "";
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}

double precicec_initialize() { return -1; }

void precicec_initializeData()
{
}

double precicec_advance(double computedTimestepLength)
{
    return -1;
}

void precicec_finalize()
{
    // print some output to check if the library is called
    printf("Finalizing solver interface");
}

int precicec_getDimensions()
{
    return fake_dimensions;
}

char precicec_isCouplingOngoing()
{
    return 0;
}

char precicec_isReadDataAvailable()
{
    return 0;
}

char precicec_isWriteDataRequired(double computedTimestepLength)
{
    return 0;
}

char precicec_isTimeWindowComplete()
{
    return 0;
}

char precicec_isActionRequired(const char *action)
{
    return 0;
}

char precicec_requiresGradientDataFor(const char *meshName, const char *dataName)
{
    return 0;
}

void precicec_precicec_markActionFulfilled(const char *action)
{
}

char precicec_hasMesh(const char *meshName)
{
    return 0;
}

char precicec_hasData(const char *dataName, int meshID)
{
    return 0;
}

char precicec_hasToEvaluateSurrogateModel()
{
    return 0;
}

char precicec_hasToEvaluateFineModel()
{
    return 0;
}

int precicec_setMeshVertex(int meshID, const double *position)
{
    return 0;
}

int precicec_getMeshVertexSize(int meshID)
{
    return n_fake_vertices;
}

void precicec_setMeshVertices(int meshID, int size, const double *positions, int *ids)
{
    assert(size == n_fake_vertices);
    for (int i = 0; i < size; i++)
    {
        ids[i] = fake_ids[i];
    }
}

void precicec_getMeshVertices(int meshID, int size, const int *ids, double *positions)
{
    for (int i = 0; i < size; i++)
    {
        positions[fake_dimensions * i] = i;
        positions[fake_dimensions * i + 1] = i + n_fake_vertices;
        positions[fake_dimensions * i + 2] = i + 2 * n_fake_vertices;
    }
}

int precicec_setMeshEdge(int meshID, int firstVertexID, int secondVertexID)
{
    return -1;
}

void precicec_setMeshTriangle(int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID)
{
}

void precicec_setMeshTriangleWithEdges(int meshID, int firstVertexID, int secondVertexID, int thirdVertexID)
{
}

void precicec_setMeshQuad(int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID, int fourthEdgeID)
{
}

void precicec_setMeshQuadWithEdges(int meshID, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)
{
}

void precicec_writeBlockVectorData(const char *meshName, const char *dataName, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size * precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeVectorData(const char *meshName, const char *dataName, int valueIndex, const double *value)
{
    for (int i = 0; i < precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = value[i];
    }
}

void precicec_writeBlockScalarData(const char *meshName, const char *dataName, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size; i++)
    {
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeScalarData(const char *meshName, const char *dataName, int valueIndex, double value)
{
    fake_read_write_buffer[0] = value;
}

void precicec_readBlockVectorData(const char *meshName, const char *dataName, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size * precicec_getDimensions(); i++)
    {
        values[i] = fake_read_write_buffer[i];
    }
}

void precicec_readVectorData(const char *meshName, const char *dataName, int valueIndex, double *value)
{
    for (int i = 0; i < precicec_getDimensions(); i++)
    {
        value[i] = fake_read_write_buffer[i];
    }
}

void precicec_readBlockScalarData(const char *meshName, const char *dataName, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size; i++)
    {
        values[i] = fake_read_write_buffer[i];
    }
}

void precicec_readScalarData(const char *meshName, const char *dataName, int valueIndex, double *value)
{
    value[0] = fake_read_write_buffer[0];
}

char *precicec_getVersionInformation()
{
    return "dummy";
}

const char *precicec_actionWriteInitialData()
{
    return "dummyWriteInitialData";
}

const char *precicec_actionWriteIterationCheckpoint()
{
    return "dummyWriteIteration";
}

const char *precicec_actionReadIterationCheckpoint()
{
    return "dummyReadIteration";
}

void precicec_writeBlockScalarGradientData(const char *meshName, const char *dataName, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size*precicec_getDimensions(); i++)
    {   
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeScalarGradientData(const char *meshName, const char *dataName, int valueIndex, const double *value)
{
    for (int i = 0; i < precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = value[i];
    }
}

void precicec_writeBlockVectorGradientData(const char *meshName, const char *dataName, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size*precicec_getDimensions()*precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeVectorGradientData(const char *meshName, const char *dataName, int valueIndex, double *value)
{
    for (int i = 0; i < precicec_getDimensions()*precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = value[i];
    }
}
